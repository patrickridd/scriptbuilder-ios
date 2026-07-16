import SwiftUI

/// A compact stat shown in the hero header (e.g. "12 Scripts").
struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}
