import SwiftUI
import DesignSystem

/// A focused single-row card prompting the user to verify their email. It sits
/// directly beneath the "Account Details" row so all identity/credential
/// actions are grouped together, separate from the "About & Legal" links.
///
/// Only meaningful when the account actually needs verification — callers
/// should gate its presence on `needsVerification`.
struct EmailVerificationCard: View {
    @Environment(\.appPalette) private var palette
    let isWorking: Bool
    let onVerifyEmail: () async -> Void

    var body: some View {
        ProfileCard(title: L10n.Card.email) {
            Button {
                Task { await onVerifyEmail() }
            } label: {
                ProfileRow(icon: "envelope.badge.fill", title: L10n.Action.verifyEmail) {
                    trailing
                }
            }
            .buttonStyle(.plain)
            .disabled(isWorking)
        }
    }

    @ViewBuilder
    private var trailing: some View {
        if isWorking {
            ProgressView().controlSize(.small)
        } else {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
    }
}
