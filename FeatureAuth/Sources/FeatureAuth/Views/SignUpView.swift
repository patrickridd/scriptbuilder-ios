import SwiftUI

public struct SignUpView: View {
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .body) private var sectionGap: CGFloat = 16

    private let config: AuthConfiguration

    public init(config: AuthConfiguration = .default,
                service: AuthService = MockAuthService(),
                onAuthenticated: @escaping (AuthUser) -> Void = { _ in }) {
        self.config = config
        _viewModel = StateObject(wrappedValue: AuthViewModel(service: service,
                                                             onAuthenticated: onAuthenticated))
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            AuthBackground()

            FitOrScrollLayout {
                VStack(spacing: sectionGap) {
                    AuthBrandHeader(title: config.appName, subtitle: config.signUpSubtitle, compact: true)

                    signUpForm
                    LabeledDivider(label: L10n.Divider.signUpWith)
                    socialRow
                    footer
                }
                .padding(.horizontal, AuthTheme.horizontalPadding)
                .padding(.vertical, 24)
            }

            closeButton
        }
        .alert(L10n.Alert.title, isPresented: alertBinding) {
            Button(L10n.Alert.ok, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(AuthTheme.textMuted)
                .padding()
        }
        .accessibilityLabel(L10n.A11y.closeSignUp)
    }

    private var signUpForm: some View {
        VStack(spacing: AuthTheme.controlSpacing) {
            HStack(spacing: AuthTheme.controlSpacing) {
                AuthTextField(
                    title: L10n.Field.firstNameTitle, placeholder: L10n.Field.firstNamePlaceholder,
                    text: $viewModel.firstName, icon: "person.fill",
                    textContentType: .givenName, capitalization: .words
                )
                AuthTextField(
                    title: L10n.Field.lastNameTitle, placeholder: L10n.Field.lastNamePlaceholder,
                    text: $viewModel.lastName, icon: "person.fill",
                    textContentType: .familyName, capitalization: .words
                )
            }
            AuthTextField(
                title: L10n.Field.emailTitle, placeholder: L10n.Field.emailPlaceholder,
                text: $viewModel.email, icon: "envelope.fill",
                textContentType: .emailAddress, keyboardType: .emailAddress
            )
            AuthTextField(
                title: L10n.Field.passwordTitle, placeholder: L10n.Field.passwordPlaceholderMin,
                text: $viewModel.password, icon: "lock.fill",
                isSecure: true, textContentType: .newPassword
            )

            AuthPrimaryButton(title: L10n.Action.createAccount, isLoading: viewModel.isLoading) {
                viewModel.signUp()
            }
            .padding(.top, 2)
        }
    }

    private var socialRow: some View {
        HStack(spacing: AuthTheme.controlSpacing) {
            SocialIconButton(style: .apple, label: L10n.A11y.signUpApple) {
                viewModel.continueWithApple()
            }
            SocialIconButton(style: .google, label: L10n.A11y.signUpGoogle) {
                viewModel.continueWithGoogle()
            }
            SocialIconButton(style: .facebook, label: L10n.A11y.signUpFacebook) {
                viewModel.continueWithFacebook()
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Text(config.signUpFooterPrompt)
                .foregroundStyle(AuthTheme.textMuted)
            Button(L10n.Action.logIn) { dismiss() }
                .fontWeight(.bold)
                .foregroundStyle(AuthTheme.accent)
        }
        .font(.subheadline)
    }
}

#Preview("Sign Up — Light") {
    SignUpView()
        .preferredColorScheme(.light)
}

#Preview("Sign Up — Dark") {
    SignUpView()
        .preferredColorScheme(.dark)
}
