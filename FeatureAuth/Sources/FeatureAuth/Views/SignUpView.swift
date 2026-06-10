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
            AuthTheme.backgroundGradient.ignoresSafeArea()
            AuthTheme.accentGlow.ignoresSafeArea()

            FitOrScrollLayout {
                VStack(spacing: sectionGap) {
                    AuthBrandHeader(title: config.appName, subtitle: config.signUpSubtitle, compact: true)

                    signUpForm
                    LabeledDivider(label: "or sign up with")
                    socialRow
                    footer
                }
                .padding(.horizontal, AuthTheme.horizontalPadding)
                .padding(.vertical, 24)
            }

            closeButton
        }
        .alert("Heads up", isPresented: alertBinding) {
            Button("OK", role: .cancel) { }
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
        .accessibilityLabel("Close sign up")
    }

    private var signUpForm: some View {
        VStack(spacing: AuthTheme.controlSpacing) {
            HStack(spacing: AuthTheme.controlSpacing) {
                AuthTextField(
                    title: "First name", placeholder: "Jane",
                    text: $viewModel.firstName, icon: "person.fill",
                    textContentType: .givenName, capitalization: .words
                )
                AuthTextField(
                    title: "Last name", placeholder: "Doe",
                    text: $viewModel.lastName, icon: "person.fill",
                    textContentType: .familyName, capitalization: .words
                )
            }
            AuthTextField(
                title: "Email", placeholder: "you@example.com",
                text: $viewModel.email, icon: "envelope.fill",
                textContentType: .emailAddress, keyboardType: .emailAddress
            )
            AuthTextField(
                title: "Password", placeholder: "At least 6 characters",
                text: $viewModel.password, icon: "lock.fill",
                isSecure: true, textContentType: .newPassword
            )

            AuthPrimaryButton(title: "Create Account", isLoading: viewModel.isLoading) {
                viewModel.signUp()
            }
            .padding(.top, 2)
        }
    }

    private var socialRow: some View {
        HStack(spacing: AuthTheme.controlSpacing) {
            SocialIconButton(style: .apple, label: "Sign up with Apple") {
                viewModel.continueWithApple()
            }
            SocialIconButton(style: .google, label: "Sign up with Google") {
                viewModel.continueWithGoogle()
            }
            SocialIconButton(style: .facebook, label: "Sign up with Facebook") {
                viewModel.continueWithFacebook()
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Text(config.signUpFooterPrompt)
                .foregroundStyle(AuthTheme.textMuted)
            Button("Log in") { dismiss() }
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
