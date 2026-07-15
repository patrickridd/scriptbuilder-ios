import Testing
@testable import DesignSystem

@Suite("DesignSystem")
struct DesignSystemTests {
    @Test("Default palette metrics")
    func defaultPaletteMetrics() {
        let palette = AppPalette.default
        #expect(palette.cornerRadius == 14)
        #expect(palette.controlHeight == 54)
        #expect(palette.horizontalPadding == 26)
        #expect(palette.controlSpacing == 12)
    }

    @Test("Cover gradient is deterministic for the same title")
    func coverGradientIsDeterministic() {
        let a = AppPalette.default.coverGradient(for: "Echoes of Tomorrow")
        let b = AppPalette.default.coverGradient(for: "Echoes of Tomorrow")
        #expect(a.startHex == b.startHex)
        #expect(a.endHex == b.endHex)
    }
}
