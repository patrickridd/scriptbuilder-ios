import SwiftUI
import DesignSystem

/// A compact circular progress indicator used for outline and character-arc
/// completion. Animates its fill from empty up to `targetFraction` on appear,
/// and — when `celebrates` is on — plays a bloom + checkmark flourish at 100%.
struct ProgressRing: View {
    @Environment(\.appPalette) private var palette

    let targetFraction: Double
    var size: CGFloat = 52
    var celebrates: Bool = true

    @State private var fraction: Double = 0
    @State private var celebrate = false
    @State private var bloom = false

    private var isComplete: Bool { targetFraction >= 0.999 }
    private var lineWidth: CGFloat { max(3, size * 0.115) }
    private var labelSize: CGFloat { max(9, size * 0.22) }
    private var showsCheckmark: Bool { isComplete && (celebrates ? celebrate : true) }

    var body: some View {
        ZStack {
            if celebrates { bloomHalo }
            ring
        }
        .frame(width: size, height: size)
        .scaleEffect(celebrate ? 1.12 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: celebrate)
        .onAppear(perform: animateIn)
        .onChange(of: targetFraction) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) { fraction = newValue }
            if newValue >= 0.999 { triggerCelebration(delay: 0.45) }
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(palette.accent.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, fraction)))
                .stroke(palette.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            label
        }
    }

    @ViewBuilder
    private var label: some View {
        if showsCheckmark {
            Image(systemName: "checkmark")
                .font(.system(size: labelSize + 2, weight: .heavy))
                .foregroundStyle(palette.accent)
                .transition(.scale.combined(with: .opacity))
        } else {
            Text("\(Int(fraction * 100))%")
                .font(.system(size: labelSize, weight: .bold, design: .rounded))
                .foregroundStyle(palette.textPrimary)
                .contentTransition(.numericText())
        }
    }

    private var bloomHalo: some View {
        Circle()
            .stroke(palette.accent.opacity(bloom ? 0 : 0.6), lineWidth: 3)
            .scaleEffect(bloom ? 1.9 : 0.9)
            .opacity(bloom ? 0 : 1)
    }

    private func animateIn() {
        withAnimation(.easeInOut(duration: 0.9).delay(0.15)) {
            fraction = targetFraction
        }
        if isComplete { triggerCelebration(delay: 1.0) }
    }

    private func triggerCelebration(delay: Double) {
        guard celebrates else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { celebrate = true }
            withAnimation(.easeOut(duration: 0.8)) { bloom = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { bloom = false }
        }
    }
}
