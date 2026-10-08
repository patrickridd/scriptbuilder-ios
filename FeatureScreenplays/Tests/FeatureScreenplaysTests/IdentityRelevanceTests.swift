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

    /// Harbinger warns; it doesn't oppose. It stays selectable for an
    /// Antagonist but is never suggested for one.
    func testAntagonistSuggestsOppositionJobsButNotHarbinger() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.antagonist)
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(
            for: role,
            archetypes: [.stock(ArchetypeSlug.villain)]
        )
        XCTAssertFalse(slugs.contains(StoryFunctionSlug.harbinger))
        for slug in [
            StoryFunctionSlug.rival, StoryFunctionSlug.pursuer,
            StoryFunctionSlug.puppeteer, StoryFunctionSlug.authority
        ] {
            XCTAssertTrue(slugs.contains(slug), slug)
        }
        let catalog = IdentityRelevance.storyFunctionCatalog(for: role).map(\.slug)
        XCTAssertTrue(catalog.contains(StoryFunctionSlug.harbinger))
    }

    func testProtagonistOnlyJobsLeadTheSuggestionList() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.protagonist)
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(
            for: role,
            archetypes: [.stock(ArchetypeSlug.hero)]
        )
        let exclusive: Set<String> = [
            StoryFunctionSlug.activeProtagonist,
            StoryFunctionSlug.passiveProtagonist,
            StoryFunctionSlug.catalystLead
        ]
        let leading = slugs.prefix(while: { exclusive.contains($0) })
        XCTAssertEqual(Set(leading), exclusive.intersection(slugs))
        XCTAssertEqual(slugs.count, Set(slugs).count)
    }

    func testSupportingOnlyJobsAreHiddenFromBothPoles() {
        for slug in [HierarchicalRole.Stock.protagonist, HierarchicalRole.Stock.antagonist] {
            let catalog = IdentityRelevance.storyFunctionCatalog(
                for: HierarchicalRole(slug: slug)
            ).map(\.slug)
            XCTAssertFalse(catalog.contains(StoryFunctionSlug.catalyst), slug)
            XCTAssertFalse(catalog.contains(StoryFunctionSlug.henchman), slug)
        }
        let recurring = IdentityRelevance.storyFunctionCatalog(
            for: HierarchicalRole(slug: HierarchicalRole.Stock.recurring)
        ).map(\.slug)
        XCTAssertTrue(recurring.contains(StoryFunctionSlug.catalyst))
        XCTAssertTrue(recurring.contains(StoryFunctionSlug.henchman))
    }

    func testSupportingOnlyJobsLeadARecurringSuggestionList() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.recurring)
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(for: role, archetypes: [])
        func index(_ slug: String) -> Int { slugs.firstIndex(of: slug) ?? Int.max }
        XCTAssertLessThan(index(StoryFunctionSlug.catalyst),
                          index(StoryFunctionSlug.comicRelief))
        XCTAssertLessThan(index(StoryFunctionSlug.henchman),
                          index(StoryFunctionSlug.herald))
    }

    func testAntagonistOppositionJobsOutrankUniversalOnes() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.antagonist)
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(for: role, archetypes: [])
        func index(_ slug: String) -> Int {
            slugs.firstIndex(of: slug) ?? Int.max
        }
        // Jobs a Protagonist is barred from are rarer, so they lead…
        XCTAssertLessThan(index(StoryFunctionSlug.heroAntagonist),
                          index(StoryFunctionSlug.thresholdGuardian))
        XCTAssertLessThan(index(StoryFunctionSlug.hiddenAntagonist),
                          index(StoryFunctionSlug.mirror))
        // …and the curated order survives inside each tier.
        XCTAssertLessThan(index(StoryFunctionSlug.tempter),
                          index(StoryFunctionSlug.saboteur))
    }

    func testNoRoleOrCustomRoleSuggestsNothingSoEverythingShows() {
        XCTAssertTrue(IdentityRelevance.suggestedArchetypeSlugs(for: nil).isEmpty)
        XCTAssertTrue(IdentityRelevance.suggestedStoryFunctionSlugs(for: .custom("Narrator")).isEmpty)
    }

    func testArchetypeAddsStoryFunctionsOnTopOfRoleSuggestions() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.fourthLead)
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(
            for: role,
            archetypes: [.stock(ArchetypeSlug.jester)]
        )
        // Rarest-first ranking wins over curated order: a supporting-only job
        // leads a Fourth Lead's list…
        XCTAssertEqual(slugs.first, StoryFunctionSlug.catalyst)
        func index(_ slug: String) -> Int { slugs.firstIndex(of: slug) ?? Int.max }
        // …the role's curated order survives inside a tier…
        XCTAssertLessThan(index(StoryFunctionSlug.comicRelief),
                          index(StoryFunctionSlug.herald))
        // …and the archetype's own functions are merged in behind the role's,
        // without duplicates.
        XCTAssertTrue(slugs.contains(StoryFunctionSlug.foil))
        XCTAssertLessThan(index(StoryFunctionSlug.comicRelief),
                          index(StoryFunctionSlug.foil))
        XCTAssertEqual(slugs.count, Set(slugs).count)
    }

    func testMentorArchetypeSuggestsVoiceOfReasonWithoutRole() {
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(
            for: nil,
            archetypes: [.stock(ArchetypeSlug.mentor)]
        )
        XCTAssertTrue(slugs.contains(StoryFunctionSlug.voiceOfReason))
        XCTAssertTrue(slugs.contains(StoryFunctionSlug.thresholdGuardian))
    }

    func testCustomArchetypesAreSkippedInSuggestionsAndSources() {
        let slugs = IdentityRelevance.suggestedStoryFunctionSlugs(
            for: nil,
            archetypes: [.custom("Time Traveller")]
        )
        XCTAssertTrue(slugs.isEmpty)
        let sources = IdentityRelevance.storyFunctionSuggestionSources(
            role: nil,
            roleName: nil,
            archetypes: [.custom("Time Traveller")]
        )
        XCTAssertTrue(sources.isEmpty)
    }

    func testSuggestionSourcesNameRoleThenArchetypes() {
        let role = HierarchicalRole(slug: HierarchicalRole.Stock.secondLead)
        let sources = IdentityRelevance.storyFunctionSuggestionSources(
            role: role,
            roleName: "Second Lead",
            archetypes: [.stock(ArchetypeSlug.mentor)]
        )
        XCTAssertEqual(sources.map(\.name), ["Second Lead", "Mentor"])
        XCTAssertEqual(sources.map(\.facet), [.role, .archetype])
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
