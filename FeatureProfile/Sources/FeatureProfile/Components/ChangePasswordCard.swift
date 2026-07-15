import SwiftUI
import DesignSystem

/// Change-password section: two secure fields with inline validation. Calls the
/// provided async action (backed by `ProfileViewModel.changePassword`) when the
/// entry is valid.
struct ChangePasswordCard: View {
    @Environment(\.appPalette) private var palette
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @FocusState private var focused: Field?
    let isWorking: Bool
    let onSubmit: (String) async -> Void

    private enum Field { case new, confirm }

    private var validationMessage: String? {
        if newPassword.isEmpty && confirmPassword.isEmpty { return nil }
        if newPassword.count < 6 { return L10n.Validation.passwordShort }
        if newPassword != confirmPassword { return L10n.Validation.passwordsMismatch }
        return nil
    }

    private var canSubmit: Bool {
        validationMessage == nil && newPassword.count >= 6
            && newPassword == confirmPassword && !isWorking
    }

    var body: some View {
        ProfileCard(title: L10n.Card.changePassword) {
            VStack(spacing: 12) {
                secureField(L10n.Field.newPassword, text: $newPassword, field: .new)
                profileDivider(palette)
                secureField(L10n.Field.confirmPassword, text: $confirmPassword, field: .confirm)
                if let validationMessage {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }
                submitButton
            }
            .padding(.vertical, 6)
        }
    }

    private func secureField(_ prompt: String, text: Binding<String>, field: Field) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(palette.brandPrimary)
                .frame(width: 28)
            SecureField(prompt, text: text)
                .textContentType(.newPassword)
                .focused($focused, equals: field)
                .foregroundStyle(palette.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var submitButton: some View {
        Button {
            Task {
                await onSubmit(newPassword)
                newPassword = ""
                confirmPassword = ""
                focused = nil
            }
        } label: {
            HStack(spacing: 8) {
                if isWorking { ProgressView().controlSize(.small) }
                Text(L10n.Action.updatePassword).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(palette.brandPrimary)
        .disabled(!canSubmit)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}
