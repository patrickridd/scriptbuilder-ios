import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var showSignUp = false
    @ScaledMetric(relativeTo: .body) private var sectionGap: CGFloat = 24

    private let config: AuthConfiguration

    public init(config: AuthConfiguration = .default,
                service: AuthService = MockAuthService(),
                onAuthenticated: @escaping (AuthUser) -> Void = { _ in }) {
        self.config = config
        _viewModel = StateObject(wrappedValue: AuthViewModel(service: service,
                                                             onAuthenticated: onAuthenticated))
    }

    public var body: some View {
        ZStack {
            AuthTheme.backgroundGradient.ignoresSafeArea()
            AuthTheme.accentGlow.ignoresSafeArea()

            FitOrScrollLayout {
                VStack(spacing: sectionGap) {
                    AuthBrandHeader(title: config.appName, subtitle: config.loginSubtitle, compact: true)

                    emailForm
                    LabeledDivider(label: "or continue with")
                    socialRow
                    footer
                }
                .padding(.horizontal, AuthTheme.horizontalPadding)
                .padding(.vertical, 24)
            }
        }
        .alert("Heads up", isPresented: alertBinding) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(config: config,
                       service: viewModel.service,
                       onAuthenticated: viewModel.onAuthenticated)
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var emailForm: some View {
        VStack(spacing: AuthTheme.controlSpacing) {
            AuthTextField(
                title: "Email", placeholder: "you@example.com",
                text: $viewModel.email, icon: "envelope.fill",
                textContentType: .emailAddress, keyboardType: .emailAddress
            )
            AuthTextField(
                title: "Password", placeholder: "Your password",
                text: $viewModel.password, icon: "lock.fill",
                isSecure: true, textContentType: .password
            )

            HStack {
                Spacer()
                Button("Forgot password?") { viewModel.forgotPassword() }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AuthTheme.textMuted)
            }

            AuthPrimaryButton(title: "Log In", isLoading: viewModel.isLoading) {
                viewModel.login()
            }
            .padding(.top, 8)
        }
    }

    private var socialRow: some View {
        HStack(spacing: AuthTheme.controlSpacing) {
            SocialIconButton(style: .apple, label: "Sign in with Apple") {
                viewModel.continueWithApple()
            }
            SocialIconButton(style: .google, label: "Sign in with Google") {
                viewModel.continueWithGoogle()
            }
            SocialIconButton(style: .facebook, label: "Continue with Facebook") {
                viewModel.continueWithFacebook()
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Text(config.loginFooterPrompt)
                .foregroundStyle(AuthTheme.textMuted)
            Button("Sign up") { showSignUp = true }
                .fontWeight(.bold)
                .foregroundStyle(AuthTheme.accent)
        }
        .font(.subheadline)
    }
}

#Preview("Login — Light") {
    LoginView()
        .preferredColorScheme(.light)
}

#Preview("Login — Dark") {
    LoginView()
        .preferredColorScheme(.dark)
}
