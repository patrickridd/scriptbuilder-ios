import SwiftUI

/// A fully custom confirmation pop-up.
///
/// System alerts inherit the surrounding tint, which on iOS 26 can render the
/// prominent cancel capsule with a label in the same colour as its fill. This
/// component owns every pixel — background, fills and label colours — so
/// contrast is guaranteed in both light and dark mode.
public struct ConfirmDialog: View {
    @Environment(\.appPalette) private var palette

    private let icon: String
    private let title: String
    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let isDestructive: Bool
    private let onConfirm: () -> Void
    private let onCancel: () -> Void

    public init(
        icon: String,
        title: String,
        message: String,
        confirmTitle: String,
        cancelTitle: String,
        isDestructive: Bool = true,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    // MARK: - Tokens

    private static let cardFill = AppPalette.dynamic(
        light: Color.white,
        dark: Color(red: 0.11, green: 0.15, blue: 0.23)
    )

    /// Muted brick red — softer than system red while keeping white text legible.
    private static let destructiveFill = AppPalette.dynamic(
        light: Color(red: 0.71, green: 0.30, blue: 0.31),
        dark: Color(red: 0.76, green: 0.36, blue: 0.37)
    )

    private var confirmFill: Color {
        isDestructive ? Self.destructiveFill : palette.brandPrimary
    }

    private var accentFill: Color {
        isDestructive ? Self.destructiveFill.opacity(0.9) : palette.brandPrimary
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 16) {
            badge
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(palette.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            buttons
        }
        .padding(22)
        .frame(maxWidth: 320)
        .background(cardBackground)
        .shadow(color: .black.opacity(0.28), radius: 28, y: 12)
    }

    private var badge: some View {
        Image(systemName: icon)
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background(Circle().fill(accentFill))
            .accessibilityHidden(true)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(Self.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(palette.cardStroke, lineWidth: 1)
            )
    }

    private var buttons: some View {
        VStack(spacing: 10) {
            Button(action: onConfirm) {
                Text(confirmTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(confirmFill)
                    )
            }
            .buttonStyle(PressableScaleStyle())

            Button(action: onCancel) {
                Text(cancelTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(palette.cardStroke.opacity(0.35))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(palette.cardStroke, lineWidth: 1)
                    )
            }
            .buttonStyle(PressableScaleStyle())
        }
        .padding(.top, 2)
    }
}

// MARK: - Presentation modifier

private struct ConfirmDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    let icon: String
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let isDestructive: Bool
    let coversNavigationBar: Bool
    let onConfirm: () -> Void

    /// Drives the transparent full-screen layer (cover mode only).
    @State private var isCoverShown = false
    /// Drives the card's own spring inside that layer (cover mode only).
    @State private var isCardVisible = false

    private static let spring = Animation.spring(response: 0.32, dampingFraction: 0.86)

    @ViewBuilder
    func body(content: Content) -> some View {
        if coversNavigationBar {
            coverBody(content: content)
        } else {
            content
                .overlay {
                    if isPresented {
                        overlayContent
                    }
                }
                .animation(Self.spring, value: isPresented)
        }
    }

    /// Hosts the pop-up in a clear full-screen cover so the dimming also
    /// covers the navigation bar (e.g. a sheet's "Done" button), which a
    /// plain overlay on the screen content can't reach.
    private func coverBody(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isCoverShown) {
                coverContent
            }
            .onChange(of: isPresented) { _, shown in
                if shown {
                    setCover(true)
                } else {
                    withAnimation(Self.spring) {
                        isCardVisible = false
                    } completion: {
                        setCover(false)
                    }
                }
            }
    }

    private var coverContent: some View {
        ZStack {
            if isCardVisible {
                overlayContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(.clear)
        .onAppear {
            withAnimation(Self.spring) { isCardVisible = true }
        }
    }

    /// Toggles the cover without the system slide-up, so only our own fade
    /// and scale are visible.
    private func setCover(_ shown: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { isCoverShown = shown }
    }

    private var overlayContent: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { close() }
            ConfirmDialog(
                icon: icon,
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                isDestructive: isDestructive,
                onConfirm: {
                    // Run the action *before* dismissing so callers that read a
                    // "pending target" bound to `isPresented` still see it.
                    onConfirm()
                    isPresented = false
                },
                onCancel: { close() }
            )
            .padding(.horizontal, 28)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private func close() {
        Haptics.selection()
        isPresented = false
    }
}

public extension View {
    /// Presents a custom, fully themed confirmation pop-up over this view.
    func confirmDialog(
        isPresented: Binding<Bool>,
        icon: String = "exclamationmark.triangle.fill",
        title: String,
        message: String,
        confirmTitle: String,
        cancelTitle: String,
        isDestructive: Bool = true,
        coversNavigationBar: Bool = false,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            ConfirmDialogModifier(
                isPresented: isPresented,
                icon: icon,
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                isDestructive: isDestructive,
                coversNavigationBar: coversNavigationBar,
                onConfirm: onConfirm
            )
        )
    }

    /// The app-wide delete pop-up: a `confirmDialog` locked to the trash badge,
    /// the destructive red button and a warning haptic, so every delete looks
    /// and feels the same. Callers inject the wording and the delete action;
    /// no copy lives in the design system.
    func deleteDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        deleteTitle: String,
        cancelTitle: String,
        coversNavigationBar: Bool = false,
        onDelete: @escaping () -> Void
    ) -> some View {
        confirmDialog(
            isPresented: isPresented,
            icon: "trash.fill",
            title: title,
            message: message,
            confirmTitle: deleteTitle,
            cancelTitle: cancelTitle,
            isDestructive: true,
            coversNavigationBar: coversNavigationBar
        ) {
            Haptics.warning()
            onDelete()
        }
    }
}
