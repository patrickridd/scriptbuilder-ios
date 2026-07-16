import SwiftUI
import DesignSystem

/// Groups lightweight support & legal actions: share app and the legal links.
/// Each row is optional and only shows when its data is present. Email
/// verification lives separately in `EmailVerificationCard`, grouped with the
/// identity/credential actions.
struct AccountActionsCard: View {
    @Environment(\.appPalette) private var palette
    let shareURL: URL?
    let reviewURL: URL?
    let privacyURL: URL?
    let termsURL: URL?

    var body: some View {
        ProfileCard(title: L10n.Card.aboutLegal) {
            VStack(spacing: 0) {
                if let shareURL {
                    shareRow(url: shareURL)
                    if hasContentAfterShare { profileDivider(palette) }
                }
                if let reviewURL {
                    linkRow(icon: "star.fill", title: L10n.Link.rateApp, url: reviewURL)
                    if privacyURL != nil || termsURL != nil { profileDivider(palette) }
                }
                if let privacyURL {
                    linkRow(icon: "hand.raised.fill", title: L10n.Link.privacy, url: privacyURL)
                    if termsURL != nil { profileDivider(palette) }
                }
                if let termsURL {
                    linkRow(icon: "doc.text.fill", title: L10n.Link.terms, url: termsURL)
                }
            }
        }
    }

    private var hasContentAfterShare: Bool {
        reviewURL != nil || privacyURL != nil || termsURL != nil
    }

    private func shareRow(url: URL) -> some View {
        ShareLink(item: url) {
            ProfileRow(icon: "square.and.arrow.up.fill", title: L10n.Link.shareApp) { chevron }
        }
        .buttonStyle(.plain)
    }

    private func linkRow(icon: String, title: String, url: URL) -> some View {
        Link(destination: url) {
            ProfileRow(icon: icon, title: title) { chevron }
        }
        .buttonStyle(.plain)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(palette.textMuted)
    }
}
