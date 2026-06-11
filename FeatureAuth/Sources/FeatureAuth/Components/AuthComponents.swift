import SwiftUI

// MARK: - Accessible Glass Text Field

/// A sleek, glassy text field with an icon and a floating label. High contrast
/// and large hit targets keep it usable for people who are hard of seeing.
public struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool
    var textContentType: UITextContentType?
    var keyboardType: UIKeyboardType
    var capitalization: TextInputAutocapitalization

    @FocusState private var isFocused: Bool

    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String = "textformat",
        isSecure: Bool = false,
        textContentType: UITextContentType? = nil,
        keyboardType: UIKeyboardType = .default,
        capitalization: TextInputAutocapitalization = .never
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.textContentType = textContentType
        self.keyboardType = keyboardType
        self.capitalization = capitalization
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(AuthTheme.accent)
                .frame(width: 22)

            field
                .font(.body.weight(.medium))
                .foregroundStyle(AuthTheme.textPrimary)
                .tint(AuthTheme.accent)
                .focused($isFocused)
                .textContentType(textContentType)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: AuthTheme.controlHeight)
        .background(AuthTheme.fieldGlass, in: RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous)
                .stroke(isFocused ? AuthTheme.accent : AuthTheme.fieldGlassStroke,
                        lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.18), value: isFocused)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var field: some View {
        let prompt = Text(placeholder).foregroundColor(AuthTheme.glassPlaceholder)
        if isSecure {
            SecureField("", text: $text, prompt: prompt)
        } else {
            TextField("", text: $text, prompt: prompt)
        }
    }
}

// MARK: - Primary Button

public struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool
    let action: () -> Void

    public init(title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AuthTheme.controlHeight)
            .background(AuthTheme.primaryButtonGradient,
                        in: RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous))
            .shadow(color: AuthTheme.brandTeal.opacity(0.45), radius: 16, y: 8)
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

// MARK: - Social Sign-In Button

public struct SocialAuthButton: View {
    public enum Style { case apple, facebook, google }

    let style: Style
    let title: String
    let action: () -> Void

    public init(style: Style, title: String, action: @escaping () -> Void) {
        self.style = style
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                leadingIcon
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AuthTheme.controlHeight)
            .background(background, in: RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous)
                    .stroke(style == .apple ? Color.clear : AuthTheme.socialStroke, lineWidth: 1)
            )
        }
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var leadingIcon: some View {
        switch style {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.title3)
                .foregroundStyle(.black)
        case .facebook:
            AuthAssets.image("FacebookLogo")
                .resizable().scaledToFit()
                .frame(width: 24, height: 24)
        case .google:
            AuthAssets.image("GoogleLogo")
                .resizable().scaledToFit()
                .frame(width: 22, height: 22)
        }
    }

    private var foreground: Color { style == .apple ? .black : .white }

    private var background: Color {
        switch style {
        case .apple: return .white
        case .facebook: return AuthTheme.facebookBlue
        case .google: return AuthTheme.googleBlue
        }
    }
}

// MARK: - Compact Social Row (icon-only, premium)

public struct SocialIconButton: View {
    let style: SocialAuthButton.Style
    let label: String
    let action: () -> Void

    public init(style: SocialAuthButton.Style, label: String, action: @escaping () -> Void) {
        self.style = style
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            icon
                .frame(maxWidth: .infinity)
                .frame(height: AuthTheme.controlHeight)
                .background(AuthTheme.fieldGlass,
                            in: RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous)
                        .stroke(AuthTheme.socialStroke, lineWidth: 1.5)
                )
        }
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private var icon: some View {
        switch style {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.title2)
                .foregroundStyle(AuthTheme.textPrimary)
        case .facebook:
            AuthAssets.image("FacebookLogo").resizable().scaledToFit().frame(width: 26, height: 26)
        case .google:
            AuthAssets.image("GoogleLogo").resizable().scaledToFit().frame(width: 24, height: 24)
        }
    }
}

// MARK: - Divider with label

public struct LabeledDivider: View {
    let label: String

    public init(label: String) {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 12) {
            line
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AuthTheme.textMuted)
            line
        }
        .accessibilityHidden(true)
    }

    private var line: some View {
        Rectangle().fill(AuthTheme.separator).frame(height: 1)
    }
}

// MARK: - Brand Header

public struct AuthBrandHeader: View {
    let title: String
    let subtitle: String
    var compact: Bool

    public init(title: String = "Script Builder", subtitle: String, compact: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.compact = compact
    }

    public var body: some View {
        VStack(spacing: compact ? 10 : 14) {
            AuthAssets.image("AppLogo")
                .resizable().scaledToFit()
                .frame(width: compact ? 56 : 68, height: compact ? 56 : 68)
                .padding(compact ? 12 : 16)
                .background(AuthTheme.logoBadge, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AuthTheme.socialStroke, lineWidth: 1)
                )

            Text(title)
                .font(.system(size: compact ? 30 : 36, weight: .bold, design: .rounded))
                .foregroundStyle(AuthTheme.textPrimary)

            Text(subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AuthTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

// MARK: - Previews

#Preview("AuthTextField — Light") {
    ComponentPreviewWrapper {
        VStack(spacing: 16) {
            AuthTextField(
                title: "Email", placeholder: "you@example.com",
                text: .constant(""), icon: "envelope.fill",
                textContentType: .emailAddress, keyboardType: .emailAddress
            )
            AuthTextField(
                title: "Password", placeholder: "At least 6 characters",
                text: .constant("hunter2"), icon: "lock.fill",
                isSecure: true, textContentType: .password
            )
        }
        .padding(.horizontal, 24)
    }
    .preferredColorScheme(.light)
}

#Preview("AuthTextField — Dark") {
    ComponentPreviewWrapper {
        VStack(spacing: 16) {
            AuthTextField(
                title: "Email", placeholder: "you@example.com",
                text: .constant(""), icon: "envelope.fill",
                textContentType: .emailAddress, keyboardType: .emailAddress
            )
        }
        .padding(.horizontal, 24)
    }
    .preferredColorScheme(.dark)
}

#Preview("AuthPrimaryButton") {
    ComponentPreviewWrapper {
        VStack(spacing: 16) {
            AuthPrimaryButton(title: "Log In", isLoading: false) { }
            AuthPrimaryButton(title: "Loading…", isLoading: true) { }
        }
        .padding(.horizontal, 24)
    }
}

#Preview("SocialIconButton Row") {
    ComponentPreviewWrapper {
        HStack(spacing: 12) {
            SocialIconButton(style: .apple, label: "Apple") { }
            SocialIconButton(style: .google, label: "Google") { }
            SocialIconButton(style: .facebook, label: "Facebook") { }
        }
        .padding(.horizontal, 24)
    }
}

#Preview("LabeledDivider") {
    ComponentPreviewWrapper {
        LabeledDivider(label: "or continue with")
            .padding(.horizontal, 24)
    }
}

#Preview("AuthBrandHeader") {
    ComponentPreviewWrapper {
        AuthBrandHeader(subtitle: "From your screen to the silver screen", compact: true)
            .padding(24)
    }
}

// MARK: - Preview Helper

/// Wraps a component in the standard app background so every preview
/// shows it in context rather than against a plain white canvas.
struct ComponentPreviewWrapper<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AuthBackground()
            content
        }
    }
}
