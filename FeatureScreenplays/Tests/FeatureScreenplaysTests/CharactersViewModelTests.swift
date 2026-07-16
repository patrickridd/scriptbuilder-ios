import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

@Suite("CharactersViewModel")
@MainActor
struct CharactersViewModelTests {

    // MARK: - Helpers

    private func makeSUT(
        characters: Set<Character> = [],
        repository: ScreenplayRepositorySpy = ScreenplayRepositorySpy()
    ) -> (sut: CharactersViewModel, spy: ScreenplayRepositorySpy) {
        let sut = CharactersViewModel(
            screenplayID: "sp-1",
            characters: characters,
            repository: repository
        )
        return (sut, repository)
    }

    // MARK: - addCharacter

    @Test("Adding a character inserts it and persists exactly once")
    func addInsertsAndPersists() async {
        let (sut, spy) = makeSUT()

        let created = await sut.addCharacter(named: "Ripley", role: "Protagonist")

        #expect(sut.characters.contains(created))
        #expect(spy.saveCharacterCallCount == 1)
        #expect(spy.savedCharacters.last?.name == "Ripley")
    }

    @Test("A blank name is allowed and kept as-is (no placeholder fallback)")
    func addAllowsBlankName() async {
        let (sut, _) = makeSUT()

        let created = await sut.addCharacter(named: "", role: nil)

        #expect(created.name.isEmpty)
        #expect(sut.characters.contains(created))
    }

    @Test("Newly added characters are inserted at the top, most-recent first")
    func addInsertsAtTop() async {
        let (sut, _) = makeSUT()

        _ = await sut.addCharacter(named: "zoe", role: nil)
        _ = await sut.addCharacter(named: "Ash", role: nil)
        _ = await sut.addCharacter(named: "kane", role: nil)

        #expect(sut.characters.map(\.name) == ["kane", "Ash", "zoe"])
    }

    @Test("Editing a character in place keeps its position (no reordering)")
    func updateKeepsPosition() async {
        let a = Character(name: "Ash")
        let b = Character(name: "Bishop")
        let (sut, _) = makeSUT(characters: [a, b])

        var edited = a
        edited.name = "Ash (revised)"
        await sut.update(edited)

        // update() persists but does not reorder — Ash stays where it was.
        #expect(sut.characters.map(\.name).contains("Ash (revised)"))
        let names = sut.characters.map(\.name)
        #expect(names.firstIndex(of: "Ash (revised)") == names.firstIndex(where: { $0 != "Bishop" }))
    }

    @Test("moveToTop bubbles the character to the top of the list")
    func moveToTopMovesCharacter() async {
        let a = Character(name: "Ash")
        let b = Character(name: "Bishop")
        let (sut, _) = makeSUT(characters: [a, b])

        sut.moveToTop(a)

        #expect(sut.characters.first?.uuid == a.uuid)
    }

    @Test("moveToTop bubbles the character's whole role section to the top")
    func moveToTopBubblesSection() async {
        let hero = Character(name: "Hero", role: "Protagonist")
        let mystery = Character(name: "Stranger", role: "Mysterious")
        let (sut, _) = makeSUT(characters: [hero, mystery])

        sut.moveToTop(mystery)

        #expect(sut.populatedRoles.first == CharacterRole.bucket(for: "Mysterious"))
        #expect(sut.characters.first?.uuid == mystery.uuid)
    }

    // MARK: - delete

    @Test("Deleting removes the character and forwards the id to the repository")
    func deleteRemovesAndForwards() async {
        let existing = Character(name: "Ripley")
        let (sut, spy) = makeSUT(characters: [existing])

        await sut.delete(existing)

        #expect(!sut.characters.contains(existing))
        #expect(spy.deletedCharacterIDs == [existing.uuid])
    }

    @Test("Deleting a missing character is a no-op on the list but still forwards")
    func deleteMissingStillForwards() async {
        let (sut, spy) = makeSUT()
        let ghost = Character(name: "Nobody")

        await sut.delete(ghost)

        #expect(sut.characters.isEmpty)
        #expect(spy.deletedCharacterIDs == [ghost.uuid])
    }

    // MARK: - Grouping

    @Test("populatedRoles lists roles ordered by their top-most character")
    func populatedRolesInOrder() async {
        let (sut, _) = makeSUT()

        // Add antagonist first, then protagonist. Because each add inserts at
        // the top, the Protagonist section (added last) should lead.
        _ = await sut.addCharacter(named: "Villain", role: "Antagonist")
        _ = await sut.addCharacter(named: "Hero", role: "Protagonist")

        #expect(sut.populatedRoles == [.protagonist, .antagonist])
    }

    @Test("Characters with unknown roles are grouped under Custom")
    func unknownRolesGroupUnderCustom() async {
        let oddball = Character(name: "Oracle", role: "Fortune Teller")
        let (sut, _) = makeSUT(characters: [oddball])

        #expect(sut.populatedRoles == [.custom])
        #expect(sut.characters(in: .custom).contains(oddball))
    }

    @Test("Deleting the last character in a section drops that section")
    func deleteLastInSectionDropsSection() async {
        let hero = Character(name: "Hero", role: "Protagonist")
        let villain = Character(name: "Villain", role: "Antagonist")
        let (sut, _) = makeSUT(characters: [hero, villain])

        await sut.delete(villain)

        #expect(!sut.populatedRoles.contains(.antagonist))
        #expect(sut.populatedRoles == [.protagonist])
    }

    @Test("Deleting one of several in a section keeps the section")
    func deleteOneKeepsSection() async {
        let a = Character(name: "Ghost A", role: "Custom")
        let b = Character(name: "Ghost B", role: "Custom")
        let (sut, _) = makeSUT(characters: [a, b])

        await sut.delete(a)

        #expect(sut.populatedRoles == [.custom])
        #expect(sut.characters(in: .custom).count == 1)
    }

    // MARK: - Regression: List section-diff crash

    /// Regression guard for the `NSInternalInconsistencyException` ("invalid
    /// number of items in section") that struck when deleting the last character
    /// in a role emptied a whole section. The stored `sections` snapshot and the
    /// derived `populatedRoles` must BOTH drop the emptied role in the same
    /// settled state the `List` diffs against — no lingering zero-row section.
    @Test("Regression: deleting the last character in a role drops it from both sections and populatedRoles")
    func deleteLastInRoleDropsFromSectionsAndPopulatedRoles() async {
        let hero = Character(name: "Hero", role: "Protagonist")
        let villain = Character(name: "Villain", role: "Antagonist")
        let (sut, _) = makeSUT(characters: [hero, villain])

        // Sanity: both role sections are present before the delete.
        #expect(sut.sections.map(\.role) == [.protagonist, .antagonist])
        #expect(sut.populatedRoles.contains(.antagonist))

        await sut.delete(villain)

        // The emptied role must be gone from the stored snapshot...
        #expect(!sut.sections.contains(where: { $0.role == .antagonist }))
        #expect(sut.sections.map(\.role) == [.protagonist])
        // ...and from the derived role list, which reads from that snapshot.
        #expect(!sut.populatedRoles.contains(.antagonist))
        #expect(sut.populatedRoles == [.protagonist])
        // No section may ever be present with zero rows (the crash condition).
        #expect(sut.sections.allSatisfy { !$0.characters.isEmpty })
        // The surviving section still holds exactly its own character.
        #expect(sut.characters(in: .protagonist).map(\.uuid) == [hero.uuid])
    }

    /// Deleting the sole character in the whole cast must leave an empty,
    /// consistent snapshot (no phantom sections) so the empty-state renders.
    @Test("Regression: deleting the only character leaves no sections at all")
    func deleteOnlyCharacterLeavesNoSections() async {
        let solo = Character(name: "Solo", role: "Protagonist")
        let (sut, _) = makeSUT(characters: [solo])

        await sut.delete(solo)

        #expect(sut.sections.isEmpty)
        #expect(sut.populatedRoles.isEmpty)
        #expect(sut.isEmpty)
    }

    // MARK: - pendingDeleteMessage

    @Test("Delete confirmation uses the character's name when present")
    func pendingDeleteMessageUsesName() async {
        let (sut, _) = makeSUT()
        sut.pendingDelete = Character(name: "Ripley")

        #expect(sut.pendingDeleteMessage.hasPrefix("Ripley and their entire arc"))
    }

    @Test("Delete confirmation falls back to a generic subject for a blank name")
    func pendingDeleteMessageBlankName() async {
        let (sut, _) = makeSUT()
        sut.pendingDelete = Character(name: "   ")

        #expect(sut.pendingDeleteMessage.hasPrefix("this character and their entire arc"))
    }

    @Test("Delete confirmation is generic when nothing is pending")
    func pendingDeleteMessageNilPending() async {
        let (sut, _) = makeSUT()

        #expect(sut.pendingDelete == nil)
        #expect(sut.pendingDeleteMessage.hasPrefix("this character and their entire arc"))
    }

    // MARK: - cardIdentity

    @Test("cardIdentity changes when any displayed field changes")
    func cardIdentityReactsToDisplayedFields() async {
        let (sut, _) = makeSUT()
        var character = Character(name: "Ripley", role: "Protagonist")
        character.intention = "Survive"

        let original = sut.cardIdentity(for: character)

        var renamed = character
        renamed.name = "Ellen Ripley"
        #expect(sut.cardIdentity(for: renamed) != original)

        var rerole = character
        rerole.role = "Antagonist"
        #expect(sut.cardIdentity(for: rerole) != original)

        var reintent = character
        reintent.intention = "Escape"
        #expect(sut.cardIdentity(for: reintent) != original)
    }

    @Test("cardIdentity is stable for identical displayed fields")
    func cardIdentityStableForSameFields() async {
        let (sut, _) = makeSUT()
        let character = Character(name: "Ripley", role: "Protagonist")

        #expect(sut.cardIdentity(for: character) == sut.cardIdentity(for: character))
    }

    // MARK: - Error handling

    @Test("A failing save surfaces the error message")
    func addSurfacesSaveError() async {
        let repo = FailingScreenplayRepositorySpy(message: "Disk is full")
        let sut = CharactersViewModel(screenplayID: "sp-1", characters: [], repository: repo)

        _ = await sut.addCharacter(named: "Ripley", role: nil)

        #expect(repo.saveCharacterCallCount == 1)
        #expect(sut.errorMessage == "Disk is full")
    }

    @Test("A failing delete surfaces the error message but still removes locally")
    func deleteSurfacesError() async {
        let existing = Character(name: "Ripley")
        let repo = FailingScreenplayRepositorySpy(message: "Network down")
        let sut = CharactersViewModel(screenplayID: "sp-1", characters: [existing], repository: repo)

        await sut.delete(existing)

        #expect(!sut.characters.contains(existing))
        #expect(repo.deleteCharacterCallCount == 1)
        #expect(sut.errorMessage == "Network down")
    }
}
