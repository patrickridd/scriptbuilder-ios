import Foundation
import Domain

/// Drives an opened screenplay's cover/editor container. Owns the repository so
/// the cover page can rename the title/author and delete the screenplay —
/// recreating the edit affordances the legacy `ScreenplayPageViewController`
/// exposed, now backed by the granular, non-destructive repository writes.
@MainActor
public final class ScreenplayDetailViewModel: ObservableObject {

    /// The live screenplay. Local edits are reflected immediately so the cover
    /// updates the moment the user saves, before the remote stream echoes back.
    @Published public private(set) var screenplay: Screenplay

    /// Set when a save/delete fails, so the UI can surface an alert.
    @Published public var errorMessage: String?

    /// Flips to `true` once a delete succeeds, letting the host pop the stack.
    @Published public private(set) var didDelete = false

    private let repository: ScreenplayRepository

    /// Exposed so the editor's Characters/Scenes tabs can perform their own
    /// granular writes against the same backing repository.
    public var screenplayRepository: ScreenplayRepository { repository }

    public init(screenplay: Screenplay, repository: ScreenplayRepository) {
        self.screenplay = screenplay
        self.repository = repository
    }

    /// Persist a renamed title / author via a scoped outline merge, leaving all
    /// nested acts, characters, and other fields untouched.
    public func rename(title: String, authorName: String) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        var fields: [OutlineField: String] = [:]
        if trimmedTitle != screenplay.title { fields[.title] = trimmedTitle }
        if trimmedAuthor != (screenplay.authorName ?? "") { fields[.authorName] = trimmedAuthor }
        guard !fields.isEmpty else { return }
        do {
            try await repository.updateOutline(fields, of: screenplay.uuid)
            if fields[.title] != nil { screenplay.title = trimmedTitle }
            if fields[.authorName] != nil {
                screenplay.authorName = trimmedAuthor.isEmpty ? nil : trimmedAuthor
            }
            screenplay.lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Permanently delete this screenplay. On success `didDelete` flips so the
    /// host can dismiss the container.
    public func delete() async {
        do {
            try await repository.delete(id: screenplay.uuid)
            didDelete = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
