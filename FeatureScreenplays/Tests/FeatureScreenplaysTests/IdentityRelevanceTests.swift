import XCTest
import Domain
@testable import FeatureScreenplays

final class IdentityRelevanceTests: XCTestCase {

    func testProtagonistSuggestsHeroButNotShadow() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.protagonist)
        let slugs = IdentityRelevance.suggestedArchetypeSlugs(for: role)
        XCTAssertTrue(slugs.contains(ArchetypeSlug.hero))
        XCTAssertFalse(slugs.contains(ArchetypeSlug.shadow))
    }

    func testAntagonistSuggestsTempterStoryFunction() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.antagonist)
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(for: role)
        XCTAssertTrue(slugs.contains(StoryFunctionSlug.tempter))
    }

    func testNoRoleOrCustomRoleSuggestsNothingSoEverythingShows() {
        XCTAssertTrue(IdentityRelevance.suggestedArchetypeSlugs(for: nil).isEmpty)
        XCTAssertTrue(IdentityRelevance.suggestedStoryFunctionSlugs(for: .custom("Narrator")).isEmpty)
    }

    func testGroupsSplitCatalogWithoutLosingEntries() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.protagonist)
        let groups = IdentityRelevance.groups(
            catalog: IdentityCatalog.archetypes,
            suggestedSlugs: IdentityRelevance.suggestedArchetypeSlugs(for: role),
            pinning: []
        )
        XCTAssertTrue(groups.isFiltering)
        XCTAssertEqual(
            groups.suggested.count + groups.others.count,
            IdentityCatalog.archetypes.count
        )
    }

    func testSelectedOffListTraitIsPinnedIntoSuggested() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.protagonist)
        let groups = IdentityRelevance.groups(
            catalog: IdentityCatalog.archetypes,
            suggestedSlugs: IdentityRelevance.suggestedArchetypeSlugs(for: role),
            pinning: [.stock(ArchetypeSlug.shadow)]
        )
        XCTAssertTrue(groups.suggested.contains { $0.slug == ArchetypeSlug.shadow })
        XCTAssertFalse(groups.others.contains { $0.slug == ArchetypeSlug.shadow })
    }

    func testEmptySuggestionsKeepFullCatalogUnfiltered() {
        let groups = IdentityRelevance.groups(
            catalog: IdentityCatalog.storyFunctions,
            suggestedSlugs: [],
            pinning: []
        )
        XCTAssertFalse(groups.isFiltering)
        XCTAssertEqual(groups.others.count, IdentityCatalog.storyFunctions.count)
    }
}
