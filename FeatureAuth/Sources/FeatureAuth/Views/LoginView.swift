import SwiftUI
import AuthDomain

public struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var showSignUp = false
    @ScaledMetric(relativeTo: .body) private var sectionGap: CGFloat = 24

    private let config: AuthConfiguration
    private let theme: AuthPalette

    public init(config: AuthConfiguration = .default,
                theme: AuthPalette = .default,
                service: AuthService = MockAuthService(),
                onAuthenticated: @escaping (AuthUser) -> Void = { _ in }) {
        self.config = config
        self.theme = theme
        AuthTheme.current = theme
        _viewModel = StateObject(wrappedValue: AuthViewModel(service: service,
                                                             onAuthenticated: onAuthenticated))
    }

    public var body: some View {
        content
            .environment(\.authPalette, theme)
            .onAppear { AuthTheme.current = theme }
    }

    private var content: some View {
        ZStack {
            AuthBackground()

            FitOrScrollLayout {
                VStack(spacing: sectionGap) {
                    AuthBrandHeader(title: config.appName, subtitle: config.loginSubtitle, compact: true)

                    emailForm
                    LabeledDivider(label: L10n.Divider.continueWith)
                    socialRow
                    footer
                }
                .padding(.horizontal, AuthTheme.horizontalPadding)
                .padding(.vertical, 24)
            }
        }
        .alert(L10n.Alert.title, isPresented: alertBinding) {
            Button(L10n.Alert.ok, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(config: config,
                       theme: theme,
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
                title: L10n.Field.emailTitle, placeholder: L10n.Field.emailPlaceholder,
                text: $viewModel.email, icon: "envelope.fill",
                textContentType: .emailAddress, keyboardType: .emailAddress
            )
            AuthTextField(
                title: L10n.Field.passwordTitle, placeholder: L10n.Field.passwordPlaceholder,
                text: $viewModel.password, icon: "lock.fill",
                isSecure: true, textContentType: .password
            )

            HStack {
                Spacer()
                Button(L10n.Action.forgotPassword) { viewModel.forgotPassword() }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AuthTheme.textMuted)
            }

            AuthPrimaryButton(title: L10n.Action.login, isLoading: viewModel.isLoading) {
                viewModel.login()
            }
            .padding(.top, 8)
        }
    }

    private var socialRow: some View {
        HStack(spacing: AuthTheme.controlSpacing) {
            SocialIconButton(style: .apple, label: L10n.A11y.signInApple) {
                viewModel.continueWithApple()
            }
            SocialIconButton(style: .google, label: L10n.A11y.signInGoogle) {
                viewModel.continueWithGoogle()
            }
            SocialIconButton(style: .facebook, label: L10n.A11y.continueFacebook) {
                viewModel.continueWithFacebook()
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Text(config.loginFooterPrompt)
                .foregroundStyle(AuthTheme.textMuted)
            Button(L10n.Action.signUp) { showSignUp = true }
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
