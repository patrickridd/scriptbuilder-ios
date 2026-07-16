import SwiftUI
import Domain
import DesignSystem

/// A compact settings sheet for a screenplay — the modern SwiftUI replacement
/// for the legacy edit affordance in `ScreenplayPageViewController`. It renames
/// the title and author, and hosts a red **Delete Screenplay** action (guarded
/// by a confirmation dialog). Purely presentational: the two side-effects are
/// handed back through `onSave` and `onDelete`.
struct ScreenplayEditSheet: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var authorName: String
    @State private var isConfirmingDelete = false

    private let onSave: (_ title: String, _ authorName: String) -> Void
    private let onDelete: () -> Void

    init(
        title: String,
        authorName: String,
        onSave: @escaping (_ title: String, _ authorName: String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        _title = State(initialValue: title)
        _authorName = State(initialValue: authorName)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.EditSheet.titleSection) {
                    TextField(L10n.EditSheet.titleSection, text: $title)
                        .textInputAutocapitalization(.words)
                }
                Section(L10n.EditSheet.authorSection) {
                    TextField(L10n.EditSheet.authorSection, text: $authorName)
                        .textInputAutocapitalization(.words)
                }
                deleteSection
            }
            .navigationTitle(L10n.EditSheet.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .confirmationDialog(
                L10n.EditSheet.deleteScreenplay,
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button(L10n.EditSheet.deleteScreenplay, role: .destructive) {
                    Haptics.warning()
                    onDelete()
                }
                Button(L10n.Action.cancel, role: .cancel) {}
            } message: {
                Text(L10n.EditSheet.deleteMessage(trimmedTitle))
            }
        }
        .tint(palette.brandPrimary)
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Label(L10n.EditSheet.deleteScreenplay, systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(L10n.Action.cancel) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(L10n.Action.save) {
                onSave(trimmedTitle, authorName.trimmingCharacters(in: .whitespacesAndNewlines))
                dismiss()
            }
            .disabled(trimmedTitle.isEmpty)
        }
    }
}

#if DEBUG
#Preview {
    ScreenplayEditSheet(
        title: "Echoes of Tomorrow",
        authorName: "Jane Rivera",
        onSave: { _, _ in },
        onDelete: {}
    )
    .environment(\.appPalette, .default)
}
#endif
