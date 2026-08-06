import SwiftUI

/// A palette-driven, auto-growing multi-line text field used across every
/// Screenplay editor tab (Characters, Scenes, Outline).
///
/// Replaces the legacy UIKit "tap the `+` row to expand" pattern with an
/// always-visible field that grows with its content (native iOS 17+ behaviour
/// via `TextField(axis: .vertical)`). Colours come entirely from `AppPalette`
/// so light/dark contrast is handled once, here, for the whole app.
public struct ExpandableTextField: View {
    @Environment(\.appPalette) private var palette
    @FocusState private var isFocused: Bool
    @State private var isExpanded = false
    @State private var headerHeight: CGFloat = 0

    private let title: String
    private let prompt: String
    private let placeholder: String
    private let systemImage: String?
    private let allowsFullScreen: Bool
    private let focusRequest: Binding<AnyHashable?>?
    private let focusID: AnyHashable?
    @Binding private var text: String

    /// - Parameters:
    ///   - title: Short section label shown above the field (e.g. "Intention").
    ///   - prompt: Longer guiding question shown beneath the title.
    ///   - placeholder: Greyed hint shown inside an empty field.
    ///   - systemImage: Optional SF Symbol shown beside the title.
    ///   - allowsFullScreen: Shows an expand button that opens a full-screen editor.
    ///   - focusRequest: A shared "please focus this field" token owned by the parent
    ///     form. When it matches `focusID` this field becomes first responder and the
    ///     token is cleared.
    ///   - focusID: This field's identity within the form — usually the same value
    ///     used for `.id(…)` so scrolling and focusing target the same field.
    ///   - text: The bound value the field edits.
    public init(
        title: String,
        prompt: String = "",
        placeholder: String = "Start writing…",
        systemImage: String? = nil,
        allowsFullScreen: Bool = true,
        focusRequest: Binding<AnyHashable?>? = nil,
        focusID: AnyHashable? = nil,
        text: Binding<String>
    ) {
        self.title = title
        self.prompt = prompt
        self.placeholder = placeholder
        self.systemImage = systemImage
        self.allowsFullScreen = allowsFullScreen
        self.focusRequest = focusRequest
        self.focusID = focusID
        self._text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(headerBackground)
                .background(headerHeightReader)
            Rectangle()
                .fill(palette.cardStroke.opacity(0.7))
                .frame(height: 1)
            editor
                .padding(16)
                .frame(minHeight: editorMinHeight, alignment: .topLeading)
        }
        .background(fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(fieldStroke)
        .fullScreenCover(isPresented: $isExpanded) {
            FullScreenTextEditor(
                title: title,
                prompt: prompt,
                placeholder: placeholder,
                systemImage: systemImage,
                text: $text
            )
        }.onTapGesture {
            isFocused = true
        }
        .onChange(of: focusRequest?.wrappedValue) { _, requested in
            handleFocusRequest(requested)
        }
    }

    /// Becomes first responder when the parent form asks for this field, then
    /// clears the token so a later tap on the same nudge works again.
    private func handleFocusRequest(_ requested: AnyHashable?) {
        guard let focusID, let requested, requested == focusID else { return }
        isFocused = true
        Task { @MainActor in
            focusRequest?.wrappedValue = nil
        }
    }

    /// The writing area opens at 1.5x the height of the label band, then
    /// grows naturally as the writer types.
    private var editorMinHeight: CGFloat {
        headerHeight > 0 ? headerHeight * 1.5 : 0
    }

    private var headerHeightReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { headerHeight = proxy.size.height }
                .onChange(of: proxy.size.height) { _, newValue in
                    headerHeight = newValue
                }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            headerText
            if allowsFullScreen {
                Spacer(minLength: 8)
                expandButton
            }
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(palette.accent)
                }
            }
            .labelStyle(.titleAndIcon)

            if !prompt.isEmpty {
                Text(prompt)
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var expandButton: some View {
        Button {
            // Make this field's own editor the first responder so the tapped
            // ExpandableTextField is the focused one, then present full screen.
            isFocused = true
            isExpanded = true
        } label: {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.accent)
                .padding(6)
                .background(
                    Circle().fill(palette.accent.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Expand \(title) to full screen")
    }

    private var editor: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.body)
            .foregroundStyle(palette.textPrimary)
            .tint(palette.accent)
            .lineLimit(1...12)
            .focused($isFocused)
            .padding(.top, 2)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isFocused {
                        Spacer()
                        doneButton
                    }
                }
            }
    }

    private var doneButton: some View {
        Button {
            isFocused = false
        } label: {
            Image(systemName: "checkmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(palette.accent)
                        .shadow(color: palette.accent.opacity(0.4), radius: 4, y: 2)
                )
        }
        .accessibilityLabel("Done editing \(title)")
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(palette.cardSurface)
    }

    /// A whisper-quiet tint that separates the label band from the writing
    /// area without turning it into a heavy toolbar.
    private var headerBackground: some View {
        ZStack {
            palette.cardSurface
            palette.accent.opacity(0.07)
            palette.textPrimary.opacity(0.04)
        }
    }

    private var fieldStroke: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(isFocused ? palette.accent.opacity(0.9) : palette.cardStroke, lineWidth: isFocused ? 1.5 : 1)
            .animation(.easeInOut(duration: 0.18), value: isFocused)
    }
}

#if DEBUG
private struct ExpandableTextFieldPreview: View {
    @State private var intention = "Escape the city before dawn."
    @State private var notes = ""
    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    ExpandableTextField(
                        title: "Intention",
                        prompt: "What does your character want?",
                        systemImage: "target",
                        text: $intention
                    )
                    ExpandableTextField(
                        title: "Notes",
                        prompt: "Any other pertinent details about the character?",
                        systemImage: "note.text",
                        text: $notes
                    )
                }
                .padding()
            }
        }
    }
}

#Preview("Light") { ExpandableTextFieldPreview() }
#Preview("Dark") { ExpandableTextFieldPreview().preferredColorScheme(.dark) }
#endif
