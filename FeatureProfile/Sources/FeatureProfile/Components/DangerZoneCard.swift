import SwiftUI
import DesignSystem

/// Destructive actions: sign out and permanently delete the account. Delete is
/// gated behind a confirmation dialog and a typed-confirmation alert to prevent
/// accidental loss, matching the legacy Settings flow.
struct DangerZoneCard: View {
    @Environment(\.appPalette) private var palette
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    let isWorking: Bool
    let onSignOut: () -> Void
    let onDelete: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            signOutButton
            deleteButton
        }
        .padding(.top, 4)
        .confirmationDialog(
            L10n.Danger.signOutTitle,
            isPresented: $showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Action.signOut, role: .destructive, action: onSignOut)
            Button(L10n.Action.cancel, role: .cancel) { }
        } message: {
            Text(L10n.Danger.signOutMessage)
        }
        .alert(L10n.Danger.deleteTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.Action.delete, role: .destructive) {
                Task { await onDelete() }
            }
            Button(L10n.Action.cancel, role: .cancel) { }
        } message: {
            Text(L10n.Danger.deleteMessage)
        }
    }

    /// Sign Out is the primary, prominent action — it's what most people
    /// actually want from this card.
    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
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
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
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
