import SwiftUI
import DesignSystem

/// A route value pushed from `ProfileView` onto the shell's `NavigationStack`.
///
/// The parent owns the `NavigationStack`, so the destination is registered via
/// `.navigationDestination(for:)` and this lightweight value simply identifies
/// which detail screen to present.
public enum ProfileRoute: Hashable {
    case accountSettings
}

/// A dedicated detail screen that hosts the "Edit Name" and "Change Password"
/// editors, moved off the main `ProfileView` to keep it uncluttered.
///
/// It shares the *same* `ProfileViewModel` instance as the parent so name and
/// password edits, `isWorking` state, and success/error alerts stay in sync and
/// feedback appears on whichever screen triggered the action.
struct AccountSettingsView: View {
    @Environment(\.appPalette) private var palette
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        ZStack {
            AppBackground()
            scrollContent
        }
        .navigationTitle(L10n.Row.accountDetails)
        .navigationBarTitleDisplayMode(.inline)
        .alert(L10n.Alert.error, isPresented: errorBinding) {
            Button(L10n.Action.ok, role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert(L10n.Alert.done, isPresented: successBinding) {
            Button(L10n.Action.ok, role: .cancel) { viewModel.successMessage = nil }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .onChange(of: viewModel.successMessage) { _, message in
            if message != nil { Haptics.success() }
        }
        .onChange(of: viewModel.errorMessage) { _, message in
            if message != nil { Haptics.warning() }
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                nameCard
                if viewModel.canChangePassword { passwordCard }
                if viewModel.needsEmailVerification { verificationCard }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var nameCard: some View {
        let parts = viewModel.nameParts
        return EditNameCard(
            firstName: parts.first,
            lastName: parts.last,
            isWorking: viewModel.isWorking
        ) { first, last in
            await viewModel.updateName(firstName: first, lastName: last)
        }
        .id(viewModel.user?.displayName ?? "")
    }

    private var passwordCard: some View {
        ChangePasswordCard(isWorking: viewModel.isWorking) { newPassword in
            await viewModel.changePassword(to: newPassword)
        }
    }

    private var verificationCard: some View {
        EmailVerificationCard(
            isWorking: viewModel.isWorking,
            onVerifyEmail: { await viewModel.sendEmailVerification() }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var successBinding: Binding<Bool> {
        Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
        )
    }
}
