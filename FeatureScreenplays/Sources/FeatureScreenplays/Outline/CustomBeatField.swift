import SwiftUI
import DesignSystem

/// A writer-authored card (custom outline beat or custom arc question).
/// Visually the twin of `ExpandableTextField` (same label band, stroke and
/// writing area) so custom and stock entries read as one list, but the title
/// and subtitle are editable, with the options menu and expand button
/// trailing the band. Wording comes from `copy`, so beats and questions each
/// keep their own vocabulary.
///
/// Focus: when the parent's `focusRequest` matches `focusID`, the title field
/// takes focus if the entry is still unnamed, otherwise the body does — so a
/// freshly added card opens ready to name.
struct CustomBeatField: View {
    @Environment(\.appPalette) private var palette

    private enum Part: Hashable { case title, subtitle, text }
    @FocusState private var focusedPart: Part?
    @State private var isExpanded = false

    @Binding var title: String
    @Binding var subtitle: String
    @Binding var text: String
    let focusRequest: Binding<AnyHashable?>
    let focusID: AnyHashable
    let onInsertAfter: () -> Void
    /// "Move Up / Move Down / Move to Act…", shown between insert and delete.
    var moveItems: [ExpandableTextField.MenuItem] = []
    let onDelete: () -> Void
    var copy: CustomFieldCopy = .beat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(headerBackground)
            Rectangle()
                .fill(palette.cardStroke.opacity(0.7))
                .frame(height: 1)
            bodyEditor
                .padding(16)
                .frame(minHeight: 64, alignment: .topLeading)
        }
        .background(palette.cardSurface, in: cardShape)
        .clipShape(cardShape)
        .overlay(stroke)
        .onChange(of: focusRequest.wrappedValue) { _, requested in
            handleFocusRequest(requested)
        }
        .onAppear { handleFocusRequest(focusRequest.wrappedValue) }
        .fullScreenCover(isPresented: $isExpanded) {
            FullScreenTextEditor(
                title: displayTitle,
                prompt: subtitle,
                placeholder: copy.textPlaceholder,
                systemImage: "sparkle",
                text: $text
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if focusedPart != nil {
                    Spacer()
                    doneButton
                }
            }
        }
    }

    private var doneButton: some View {
        Button {
            focusedPart = nil
        } label: {
            Image(systemName: "checkmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(palette.accent))
        }
        .accessibilityLabel(L10n.CustomBeatCopy.doneEditing)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
    }

    private func handleFocusRequest(_ requested: AnyHashable?) {
        guard let requested, requested == focusID else { return }
        let isUnnamed = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        focusedPart = isUnnamed ? .title : .text
        Task { @MainActor in focusRequest.wrappedValue = nil }
    }

    // MARK: - Header band

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkle")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.accent)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                titleField
                subtitleField
            }
            optionsMenu
            expandButton
        }
    }

    private var titleField: some View {
        TextField(copy.titlePlaceholder, text: $title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.textPrimary)
            .tint(palette.accent)
            .focused($focusedPart, equals: .title)
            .submitLabel(.next)
            .onSubmit { focusedPart = .subtitle }
    }

    private var subtitleField: some View {
        TextField(copy.subtitlePlaceholder, text: $subtitle)
            .font(.caption)
            .foregroundStyle(palette.textMuted)
            .tint(palette.accent)
            .focused($focusedPart, equals: .subtitle)
            .submitLabel(.next)
            .onSubmit { focusedPart = .text }
    }

    private var expandButton: some View {
        Button {
            focusedPart = nil
            isExpanded = true
        } label: {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.accent)
                .padding(6)
                .background(Circle().fill(palette.accent.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.CustomBeatCopy.expand)
    }

    private var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? copy.untitled : trimmed
    }

    private var optionsMenu: some View {
        Menu {
            Button(action: onInsertAfter) {
                Label(copy.insertAfter, systemImage: "plus.square.on.square")
            }
            if !moveItems.isEmpty {
                Section {
                    ForEach(moveItems) { item in
                        Button(action: item.action) {
                            Label(item.title, systemImage: item.systemImage)
                        }
                    }
                }
            }
            Button(role: .destructive, action: onDelete) {
                Label(copy.delete, systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote.weight(.bold))
                .foregroundStyle(palette.accent)
                .frame(width: 26, height: 26)
                .background(Circle().fill(palette.accent.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(copy.options)
    }

    // MARK: - Writing area

    private var bodyEditor: some View {
        TextField(copy.textPlaceholder, text: $text, axis: .vertical)
            .font(.body)
            .foregroundStyle(palette.textPrimary)
            .tint(palette.accent)
            .lineLimit(1...12)
            .focused($focusedPart, equals: .text)
            .contentShape(Rectangle())
            .onTapGesture { focusedPart = .text }
    }

    // MARK: - Chrome

    private var headerBackground: some View {
        ZStack {
            palette.cardSurface
            palette.accent.opacity(0.07)
            palette.textPrimary.opacity(0.04)
        }
    }

    private var stroke: some View {
        let isFocused = focusedPart != nil
        return cardShape
            .strokeBorder(
                isFocused ? palette.accent.opacity(0.9) : palette.accent.opacity(0.35),
                lineWidth: isFocused ? 1.5 : 1
            )
            .animation(.easeInOut(duration: 0.18), value: isFocused)
    }
}
