import SwiftUI

/// A reusable, palette-driven full-screen editor for a single block of text.
///
/// Presented via `.fullScreenCover` (e.g. from `ExpandableTextField`'s expand
/// button), it gives writers a comfortable, distraction-light canvas to read
/// and edit long-form content — a modern SwiftUI replacement for the legacy
/// UIKit `expandButtonTapped` modal.
///
/// The editor binds `TextEditor` directly to the caller's binding, so every
/// keystroke propagates immediately. Callers must supply a real state-backed
/// binding (e.g. `$model.field`) — hand-made `Binding(get:set:)` closures go
/// stale inside `fullScreenCover` and silently drop writes.
public struct FullScreenTextEditor: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private let title: String
    private let prompt: String
    private let placeholder: String
    private let systemImage: String?
    @Binding private var text: String

    /// Local working copy. The editor edits this in isolation so keystrokes
    /// never mutate the caller's binding mid-edit (which would re-render the
    /// presenting view and tear down the cover, dropping all but the first
    /// character). We commit back to `text` once, on Done / disappear.
    @State private var draft: String

    public init(
        title: String,
        prompt: String = "",
        placeholder: String = "Start writing…",
        systemImage: String? = nil,
        text: Binding<String>
    ) {
        self.title = title
        self.prompt = prompt
        self.placeholder = placeholder
        self.systemImage = systemImage
        self._text = text
        self._draft = State(initialValue: text.wrappedValue)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                content
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
        .task {
            // Refresh the working copy from the caller's latest value each time
            // the editor is presented — the cover view can be reused across
            // presentations, so the init-time `draft` may be stale after the
            // inline field was edited. Sync before grabbing focus.
            draft = text
            // Grabbing focus immediately in onAppear can race the
            // fullScreenCover presentation animation and silently fail;
            // a short delay makes the keyboard appear reliably.
            try? await Task.sleep(nanoseconds: 450_000_000)
            isFocused = true
        }
        .onDisappear { commit() }
    }

    /// Writes the isolated draft back to the caller's binding exactly once.
    private func commit() {
        if text != draft { text = draft }
    }

    // MARK: - Subviews

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !prompt.isEmpty {
                promptLabel
            }
            editor
        }
        .padding(20)
    }

    private var promptLabel: some View {
        Label {
            Text(prompt)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
        } icon: {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
        }
        .labelStyle(.titleAndIcon)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            editorBackground
            if draft.isEmpty && !isFocused {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(palette.textMuted)
                    .padding(EdgeInsets(top: 16, leading: 13, bottom: 0, trailing: 0))
                    .allowsHitTesting(false)
            }
            TextEditor(text: $draft)
                .font(.body)
                .foregroundStyle(palette.textPrimary)
                .tint(palette.accent)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .padding(8)
        }
    }

    private var editorBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(palette.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(palette.cardStroke, lineWidth: 1)
            )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(action: dismissButtonTapped) {
                Image(systemName: "checkmark")
            }
            .font(.body.weight(.semibold))
            .tint(palette.accent)
            .accessibilityIdentifier("fullScreenEditor.done")
        }
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                isFocused = false
            }
            .font(.body.weight(.semibold))
            .tint(palette.accent)
            .accessibilityIdentifier("fullScreenEditor.keyboardDone")
        }
    }

    private func dismissButtonTapped() {
        isFocused = false
        commit()
        dismiss()
    }
}

#if DEBUG
/// Renders the editor directly (no `fullScreenCover`) because the Xcode
/// Preview canvas cannot reliably route keyboard input into modal covers.
/// In the real app it is always presented as a cover by `ExpandableTextField`.
private struct FullScreenTextEditorPreview: View {
    @State private var text = "Recover the stolen memory and prove the AI is lying."
    var body: some View {
        FullScreenTextEditor(
            title: "Intention",
            prompt: "What does your character want?",
            systemImage: "target",
            text: $text
        )
    }
}

#Preview("Light") { FullScreenTextEditorPreview() }
#Preview("Dark") { FullScreenTextEditorPreview().preferredColorScheme(.dark) }
#endif
