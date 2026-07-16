import SwiftUI
import Domain
import DesignSystem

/// The paged composition root for an opened screenplay. Page 0 is the
/// `ScreenplayCoverView`; page 1 is the working editor. They're bound together
/// with the book-style **page-curl** transition, recreating the feel of the
/// legacy `ScreenplayPageViewController`.
///
/// "Start writing" on the cover curls forward to the editor; the user can also
/// turn the page directly with a swipe, and curl back to the cover.
///
/// The container also owns the **edit** (rename title/author) and **delete**
/// affordances the legacy editor exposed, driven through
/// `ScreenplayDetailViewModel` and the repository.
public struct ScreenplayContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ScreenplayDetailViewModel
    @State private var pageIndex = 0
    @State private var isEditing = false
    private let gate: EditorGate

    /// Invoked after a successful delete so the host can also refresh / pop.
    private let onDelete: () -> Void

    /// Invoked after the user shares/exports this screenplay — the app layer
    /// uses this as a "moment of delight" to consider a review prompt.
    private let onShared: () -> Void

    /// Invoked when the outline first becomes fully complete — another
    /// "moment of delight" the app layer feeds to the review trigger.
    private let onOutlineCompleted: () -> Void

    public init(
        screenplay: Screenplay,
        repository: ScreenplayRepository,
        gate: EditorGate = .unrestricted,
        onDelete: @escaping () -> Void = {},
        onShared: @escaping () -> Void = {},
        onOutlineCompleted: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: ScreenplayDetailViewModel(screenplay: screenplay, repository: repository)
        )
        self.gate = gate
        self.onDelete = onDelete
        self.onShared = onShared
        self.onOutlineCompleted = onOutlineCompleted
    }

    public var body: some View {
        PageCurlView(pageIndex: $pageIndex) {
            ScreenplayCoverView(screenplay: viewModel.screenplay) {
                withAnimation { pageIndex = 1 }
            } onShared: {
                onShared()
            }
        } trailing: {
            ScreenplayEditorView(
                screenplay: viewModel.screenplay,
                repository: viewModel.screenplayRepository,
                gate: gate,
                onOutlineCompleted: onOutlineCompleted
            )
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .disableZoomInteractiveDismiss()
        .toolbar { toolbar }
        .sheet(isPresented: $isEditing) { editSheet }
        .alert(
            L10n.Action.somethingWentWrong,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.Action.ok, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted {
                isEditing = false
                onDelete()
                dismiss()
            }
        }
    }

    private var editSheet: some View {
        ScreenplayEditSheet(
            title: viewModel.screenplay.title,
            authorName: viewModel.screenplay.authorName ?? "",
            onSave: { title, author in
                Task { await viewModel.rename(title: title, authorName: author) }
            },
            onDelete: {
                Task { await viewModel.delete() }
            }
        )
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                if pageIndex == 1 {
                    withAnimation { pageIndex = 0 }
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: pageIndex == 1 ? "chevron.left" : "xmark")
            }
            .accessibilityLabel(pageIndex == 1 ? L10n.Cover.coverLabel : L10n.Action.close)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isEditing = true
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel(L10n.Cover.screenplaySettings)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ScreenplayContainerView(
            screenplay: Screenplay(
                title: "Echoes of Tomorrow",
                authorName: "Jane Rivera",
                logLine: "A stranded engineer must trust a fading AI to make it home."
            ),
            repository: MockScreenplayRepository()
        )
        .environment(\.appPalette, .default)
    }
}
#endif
