import SwiftUI
import DesignSystem

/// A lightweight swipe-to-delete container for cards living inside a
/// `ScrollView` + `LazyVStack` (where the native List `.swipeActions` modifier
/// isn't available). A trailing drag reveals a red "Delete" pill; tapping it —
/// or dragging past the commit threshold — fires `onDelete`. Any other gesture
/// snaps the card closed.
struct SwipeToDeleteRow<Content: View>: View {
    @Environment(\.appPalette) private var palette

    let onDelete: () -> Void
    @ViewBuilder var content: Content

    /// How wide the revealed action area is.
    private let actionWidth: CGFloat = 88
    /// Drag distance past which we auto-commit the delete on release.
    private let commitThreshold: CGFloat = 220

    @State private var offset: CGFloat = 0
    @GestureState private var dragTranslation: CGFloat = 0

    private var currentOffset: CGFloat {
        // Only allow dragging left (negative). Clamp the rubber-band a bit past
        // the action width so the button feels reachable but not unbounded.
        min(0, max(-commitThreshold - 40, offset + dragTranslation))
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteAction
            content
                .offset(x: currentOffset)
                .gesture(dragGesture)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: offset)
    }

    private var deleteAction: some View {
        Button {
            close()
            onDelete()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "trash.fill")
                    .font(.body.weight(.semibold))
                Text(L10n.Action.delete)
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(width: actionWidth)
            .frame(maxHeight: .infinity)
            .background(Color.red, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .opacity(currentOffset < -8 ? 1 : 0)
        .accessibilityLabel("Delete scene")
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($dragTranslation) { value, state, _ in
                // Ignore predominantly-vertical drags so scrolling still works.
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                let projected = offset + value.translation.width
                if projected < -commitThreshold {
                    close()
                    onDelete()
                } else if projected < -actionWidth / 2 {
                    offset = -actionWidth
                } else {
                    offset = 0
                }
            }
    }

    private func close() {
        offset = 0
    }
}
