import SwiftUI

// MARK: - Accessible Glass Text Field

/// A sleek, glassy text field with an icon and a floating label. High contrast
/// and large hit targets keep it usable for people who are hard of seeing.
struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String = "textformat"
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .never

    @FocusState private var isFocused: Bool

    var body: some View {
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
                        lineWidth: isFocused ? 1.5 : 1)
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

struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
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

struct SocialAuthButton: View {
    enum Style { case apple, facebook, google }

    let style: Style
    let title: String
    let action: () -> Void

    var body: some View {
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
            Image("FacebookLogo")
                .resizable().scaledToFit()
                .frame(width: 24, height: 24)
        case .google:
            Image("GoogleLogo")
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

struct SocialIconButton: View {
    let style: SocialAuthButton.Style
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
                .frame(maxWidth: .infinity)
                .frame(height: AuthTheme.controlHeight)
                .background(AuthTheme.fieldGlass,
                            in: RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AuthTheme.cornerRadius, style: .continuous)
                        .stroke(AuthTheme.socialStroke, lineWidth: 1)
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
            Image("FacebookLogo").resizable().scaledToFit().frame(width: 26, height: 26)
        case .google:
            Image("GoogleLogo").resizable().scaledToFit().frame(width: 24, height: 24)
        }
    }
}

// MARK: - Divider with label

struct LabeledDivider: View {
    let label: String

    var body: some View {
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

struct AuthBrandHeader: View {
    let subtitle: String
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 10 : 14) {
            Image("AppLogo")
                .resizable().scaledToFit()
                .frame(width: compact ? 56 : 68, height: compact ? 56 : 68)
                .padding(compact ? 12 : 16)
                .background(AuthTheme.logoBadge, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AuthTheme.socialStroke, lineWidth: 1)
                )

            Text("Script Builder")
                .font(.system(size: compact ? 30 : 36, weight: .bold, design: .rounded))
                .foregroundStyle(AuthTheme.textPrimary)

            Text(subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AuthTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Script Builder. \(subtitle)")
    }
}
