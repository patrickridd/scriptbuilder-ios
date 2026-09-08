import SwiftUI
import DesignSystem

/// The shared completion header used by the character, outline-section, and
/// scene editors: a bold title, a live "X of Y fields complete" subtitle, an
/// animated `ProgressRing`, and an optional "Next up: …" nudge that jumps the
/// writer to the first still-empty field.
struct ProgressHeader: View {
    @Environment(\.appPalette) private var palette

    let title: String
    /// Optional SF Symbol shown leading the title.
    var systemImage: String?
    /// When true the title is rendered as a soft prompt (muted, lighter weight)
    /// because the real value has not been entered yet.
    var titleIsPlaceholder: Bool = false
    /// Optional action fired when a placeholder title is tapped.
    var onTitleTapped: (() -> Void)?
    /// When supplied the title becomes an inline text field, so the biggest
    /// thing on the screen *is* the value rather than a label for it.
    var titleBinding: Binding<String>?
    /// Prompt shown while an editable title is empty.
    var titlePlaceholder: String = ""
    /// Accessibility label for the editable title (the visible text is the value).
    var titleAccessibilityLabel: String = ""
    /// Focus binding owned by the parent so nudges can jump straight here.
    var titleFocus: FocusState<Bool>.Binding?
    let filled: Int
    let total: Int
    /// Copy shown when every counted field has content.
    let completeText: String
    /// Localized title of the first empty field, if any.
    var nextFieldTitle: String?
    var onNextTapped: (() -> Void)?
    /// Trailing glyph on the nudge: an arrow when the tap scrolls down this
    /// screen, a chevron when it pushes a whole editor.
    var nextFieldGlyph: String = "arrow.down.circle.fill"

    private var isComplete: Bool { total > 0 && filled == total }

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(filled) / Double(total)
    }

    private var subtitle: String {
        isComplete ? completeText : L10n.Progress.fieldsComplete(filled, total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleRow
                .frame(maxWidth: .infinity, alignment: .leading)
            summaryRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .accessibilityElement(children: titleBinding == nil ? .combine : .contain)
        .accessibilityLabel(L10n.Progress.accessibility(title, filled, total))
    }

    /// The title now owns the full width; the ring sits beside the smaller
    /// status copy so long names never have to compete with it for space.
    private var summaryRow: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: subtitle)
                    .padding(.leading, 2)
                if !isComplete, let nextFieldTitle, let onNextTapped {
                    nudge(title: nextFieldTitle, action: onNextTapped)
                }
            }
            Spacer(minLength: 8)
            ProgressRing(targetFraction: fraction, size: 46)
        }
    }

    @ViewBuilder
    private var titleRow: some View {
        if titleBinding != nil {
            editableTitle
        } else if titleIsPlaceholder, let onTitleTapped {
            Button {
                Haptics.selection()
                onTitleTapped()
            } label: {
                titleLabel
            }
            .buttonStyle(PressableScaleStyle())
        } else {
            titleLabel
        }
    }

    /// Height of one line of the title font, used to park the leading icon on
    /// the first line no matter how the title (or empty field) measures itself.
    private var titleLineHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title1).lineHeight
    }

    @ViewBuilder
    private var titleIcon: some View {
        if let systemImage {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(titleIsPlaceholder ? palette.textMuted : palette.accent)
                .frame(height: titleLineHeight)
        }
    }

    private var titleLabel: some View {
        HStack(alignment: .top, spacing: 8) {
            titleIcon
            Text(title)
                .font(titleIsPlaceholder ? .title.weight(.semibold) : .title.weight(.bold))
                .foregroundStyle(titleIsPlaceholder ? palette.textMuted : palette.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: titleIsPlaceholder)
    }

    /// The title rendered as a borderless field: it reads as plain text until
    /// tapped, then the caret appears exactly where the name already sits.
    private var editableTitle: some View {
        HStack(alignment: .top, spacing: 6) {
            titleIcon
            titleTextField
                .frame(minHeight: titleLineHeight, alignment: .leading)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var titleTextField: some View {
        let binding = titleBinding ?? .constant("")
        let focus = titleFocus
        let field = TextField(
            "",
            text: binding,
            prompt: Text(titlePlaceholder).foregroundColor(palette.textMuted),
            axis: .vertical
        )
        .font(.title.weight(.bold))
        .foregroundStyle(palette.textPrimary)
        .tint(palette.accent)
        .lineLimit(1...3)
        .submitLabel(.done)
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
        .frame(width: nil)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: binding.wrappedValue) { _, newValue in
            // A vertical field turns Return into a newline; treat it as "done".
            guard newValue.contains(where: \.isNewline) else { return }
            binding.wrappedValue = newValue
                .components(separatedBy: .newlines)
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespaces)
            focus?.wrappedValue = false
        }
        .accessibilityLabel(titleAccessibilityLabel)

        if let focus {
            field.focused(focus)
        } else {
            field
        }
    }

    private func nudge(title: String, action: @escaping () -> Void) -> some View {        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.caption2.weight(.semibold))
                Text(L10n.Progress.nextUp(title))
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                Image(systemName: nextFieldGlyph)
                    .font(.caption2)
            }
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(palette.accent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityHint(L10n.Progress.nextUpHint)
    }
}

// MARK: - Previews

#if DEBUG
/// Shows the editable-title variant: the title itself is the text field, so
/// tapping it (or "Change Name" in the nav bar menu) starts editing.
private struct EditableTitlePreview: View {
    let label: String
    @State var name: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ProgressHeader(
                title: name,
                systemImage: "person.fill",
                titleBinding: $name,
                titlePlaceholder: "Name this character",
                titleAccessibilityLabel: "Character name",
                titleFocus: $focused,
                filled: 3,
                total: 8,
                completeText: "Every detail filled in ✨",
                nextFieldTitle: "Backstory",
                onNextTapped: {}
            )
            Button(focused ? "Unfocus title" : "Focus title") {
                focused.toggle()
            }
            .font(.caption)
        }
    }
}

private struct ProgressHeaderPreview: View {
    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 32) {
                    EditableTitlePreview(label: "EDITABLE TITLE", name: "Marlowe")
                    EditableTitlePreview(label: "LONG NAME", name: "Evangeline Ashworth-Blake")
                    EditableTitlePreview(label: "EMPTY (PROMPT)", name: "")
                    ProgressHeader(
                        title: "Scene Progress",
                        systemImage: "film",
                        filled: 2,
                        total: 6,
                        completeText: "Scene complete — nice work!",
                        nextFieldTitle: "Dialogue",
                        onNextTapped: {}
                    )
                    ProgressHeader(
                        title: "Act One",
                        systemImage: "list.bullet.rectangle",
                        filled: 5,
                        total: 6,
                        completeText: "Act complete!",
                        nextFieldTitle: "Inciting Incident",
                        onNextTapped: {}
                    )
                    ProgressHeader(
                        title: "Character",
                        systemImage: "person.fill",
                        filled: 8,
                        total: 8,
                        completeText: "Every detail filled in ✨"
                    )
                    ProgressHeader(
                        title: "No Icon, Just Starting",
                        filled: 0,
                        total: 6,
                        completeText: "Done!",
                        nextFieldTitle: "Scene Description",
                        onNextTapped: {}
                    )
                }
                .padding(20)
            }
        }
    }
}

#Preview("Progress Header — Light") { ProgressHeaderPreview() }
#Preview("Progress Header — Dark") { ProgressHeaderPreview().preferredColorScheme(.dark) }

#Preview("Editable Title") {
    ZStack {
        AppBackground()
        VStack(alignment: .leading, spacing: 28) {
            EditableTitlePreview(label: "SHORT NAME", name: "Marlowe")
            EditableTitlePreview(label: "LONG NAME", name: "Evangeline Ashworth-Blake")
            EditableTitlePreview(label: "EMPTY (PROMPT)", name: "")
            Spacer()
        }
        .padding(20)
    }
}
#endif
