import SwiftUI
import DesignSystem

/// Destructive actions: sign out and permanently delete the account.
///
/// The card only renders the two buttons. The confirmation pop-ups are
/// attached by `ProfileView` at screen level (`dangerZoneDialogs`) — a
/// `confirmDialog` overlay on this card would be confined to the card's own
/// frame inside the scroll view and render clipped.
struct DangerZoneCard: View {
    @Environment(\.appPalette) private var palette
    let isWorking: Bool
    let onSignOutTap: () -> Void
    let onDeleteTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            signOutButton
            deleteButton
        }
        .padding(.top, 4)
    }

    /// Sign Out is the primary, prominent action — it's what most people
    /// actually want from this card.
    private var signOutButton: some View {
        Button(action: onSignOutTap) {
            Label(L10n.Action.signOut, systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(palette.accent)
    }

    /// Delete is intentionally de-emphasized: a quiet plain text link rather than
    /// a filled button, so it can't be mistaken for Sign Out.
    private var deleteButton: some View {
        Button(role: .destructive, action: onDeleteTap) {
            HStack(spacing: 6) {
                if isWorking { ProgressView().controlSize(.small) }
                Text(L10n.Action.deleteAccount)
                    .font(.footnote.weight(.regular))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .disabled(isWorking)
    }
}

/// Screen-level confirmations for `DangerZoneCard`. Apply to the root of the
/// screen so the pop-up and dimming cover the whole display.
struct DangerZoneDialogs: ViewModifier {
    @Binding var showSignOut: Bool
    @Binding var showDelete: Bool
    let onSignOut: () -> Void
    let onDelete: () async -> Void

    func body(content: Content) -> some View {
        content
            // Signing out is reversible, so it uses the brand colour, not red.
            .confirmDialog(
                isPresented: $showSignOut,
                icon: "rectangle.portrait.and.arrow.right",
                title: L10n.Danger.signOutTitle,
                message: L10n.Danger.signOutMessage,
                confirmTitle: L10n.Action.signOut,
                cancelTitle: L10n.Action.cancel,
                isDestructive: false,
                coversNavigationBar: true,
                onConfirm: onSignOut
            )
            .deleteDialog(
                isPresented: $showDelete,
                title: L10n.Danger.deleteTitle,
                message: L10n.Danger.deleteMessage,
                deleteTitle: L10n.Action.delete,
                cancelTitle: L10n.Action.cancel,
                coversNavigationBar: true
            ) {
                Task { await onDelete() }
            }
    }
}
