import Testing
import Domain
@testable import FeatureScreenplays

@Suite("FeatureScreenplays")
@MainActor
struct FeatureScreenplaysTests {
    @Test("Search filter narrows results")
    func filterNarrowsResults() async {
        let repo = MockScreenplayRepository(seedSamples: true)
        let vm = ScreenplaysViewModel(repository: repo)
        await vm.refresh()
        let total = vm.filteredScreenplays.count
        #expect(total > 0)
        vm.searchText = "zzz-no-match-zzz"
        #expect(vm.filteredScreenplays.count == 0)
    }
}
