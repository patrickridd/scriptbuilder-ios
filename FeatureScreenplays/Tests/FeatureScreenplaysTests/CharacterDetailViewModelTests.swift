import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

@Suite("CharacterDetailViewModel")
@MainActor
struct CharacterDetailViewModelTests {

    // MARK: - Helpers

    private func makeViewModel(
        repository: ScreenplayRepository = MockScreenplayRepository(seedSamples: false)
    ) -> CharactersViewModel {
        CharactersViewModel(
            screenplayID: "sp-1",
            characters: [],
            repository: repository
        )
    }

    private func makeSUT(
        character: Character,
        repository: ScreenplayRepository = MockScreenplayRepository(seedSamples: false),
        debounce: Duration = .milliseconds(500)
    ) -> (sut: CharacterDetailViewModel, viewModel: CharactersViewModel) {
        let viewModel = makeViewModel(repository: repository)
        let sut = CharacterDetailViewModel(
            character: character,
            viewModel: viewModel,
            debounce: debounce
        )
        return (sut, viewModel)
    }

    // MARK: - shouldFocusName

    @Test("Focuses the name field for a brand-new unnamed character")
    func focusesWhenNameEmpty() {
        let (sut, _) = makeSUT(character: Character(name: ""))
        #expect(sut.shouldFocusName == true)
    }

    @Test("Does not steal focus when editing a named character")
    func noFocusWhenNamed() {
        let (sut, _) = makeSUT(character: Character(name: "Ripley"))
        #expect(sut.shouldFocusName == false)
    }

    // MARK: - navigationTitle

    @Test("Shows placeholder title while the character is unnamed")
    func placeholderTitleWhenEmpty() {
        let (sut, _) = makeSUT(character: Character(name: ""))
        #expect(sut.navigationTitle == "Character")
    }

    @Test("Shows the character name as the title once set")
    func titleReflectsName() {
        let (sut, _) = makeSUT(character: Character(name: "Ripley"))
        #expect(sut.navigationTitle == "Ripley")
    }

    // MARK: - Role bucketing on init

    @Test("A known stored role maps to its matching bucket")
    func knownRoleBucket() {
        let (sut, _) = makeSUT(character: Character(name: "Hero", role: "Protagonist"))
        #expect(sut.role == .protagonist)
        #expect(sut.customRole.isEmpty)
    }

    @Test("An unknown stored role falls into the custom bucket and preserves the text")
    func unknownRoleBecomesCustom() {
        let (sut, _) = makeSUT(character: Character(name: "Oracle", role: "Fortune Teller"))
        #expect(sut.role == .custom)
        #expect(sut.customRole == "Fortune Teller")
    }

    @Test("A missing stored role defaults to the custom bucket with empty text")
    func missingRoleBecomesCustom() {
        let (sut, _) = makeSUT(character: Character(name: "Extra", role: nil))
        #expect(sut.role == .custom)
        #expect(sut.customRole.isEmpty)
    }

    // MARK: - flush()

    @Test("Flush persists the latest edits immediately")
    func flushPersistsLatestEdits() async {
        let spy = ScreenplayRepositorySpy()
        let (sut, viewModel) = makeSUT(character: Character(name: "Ripley"), repository: spy)

        sut.draft.name = "Ellen Ripley"
        await sut.flush()

        let saved = spy.savedCharacters
        #expect(saved.last?.name == "Ellen Ripley")
        #expect(viewModel.characters.first?.name == "Ellen Ripley")
    }

    @Test("Flush resolves a custom role from the picker + free-form text")
    func flushResolvesCustomRole() async {
        let spy = ScreenplayRepositorySpy()
        let (sut, _) = makeSUT(character: Character(name: "Oracle"), repository: spy)

        sut.role = .custom
        sut.customRole = "  Fortune Teller  "
        await sut.flush()

        let saved = spy.savedCharacters
        #expect(saved.last?.role == "Fortune Teller")
    }

    @Test("Flush writes a picked standard role as its raw value")
    func flushResolvesStandardRole() async {
        let spy = ScreenplayRepositorySpy()
        let (sut, _) = makeSUT(character: Character(name: "Hero"), repository: spy)

        sut.role = .antagonist
        await sut.flush()

        let saved = spy.savedCharacters
        #expect(saved.last?.role == "Antagonist")
    }

    @Test("An empty custom role is stored as nil, not an empty string")
    func flushEmptyCustomRoleBecomesNil() async {
        let spy = ScreenplayRepositorySpy()
        let (sut, _) = makeSUT(character: Character(name: "Extra"), repository: spy)

        sut.role = .custom
        sut.customRole = "   "
        await sut.flush()

        let saved = spy.savedCharacters
        #expect(saved.last?.role == nil)
    }

    @Test("Flush cancels a pending debounced save so it only writes once")
    func flushCancelsPendingDebounce() async throws {
        let spy = ScreenplayRepositorySpy()
        // Long debounce so the scheduled autosave cannot fire before we flush.
        let (sut, _) = makeSUT(
            character: Character(name: "Ripley"),
            repository: spy,
            debounce: .seconds(10)
        )

        // Schedule a debounced save, then immediately flush.
        sut.draft.name = "Ellen Ripley"
        await sut.flush()

        // Give the (now-cancelled) debounce ample time to prove it won't fire.
        try await Task.sleep(for: .milliseconds(200))

        #expect(spy.saveCharacterCallCount == 1)
        #expect(spy.savedCharacters.last?.name == "Ellen Ripley")
    }

    // MARK: - Debounced autosave

    @Test("Editing a field autosaves after the debounce window")
    func editAutosavesAfterDebounce() async throws {
        let spy = ScreenplayRepositorySpy()
        let (sut, _) = makeSUT(
            character: Character(name: "Ripley"),
            repository: spy,
            debounce: .milliseconds(50)
        )

        sut.draft.intention = "Survive"
        try await Task.sleep(for: .milliseconds(200))

        let saved = spy.savedCharacters
        #expect(saved.contains { $0.intention == "Survive" })
    }

    @Test("Rapid successive edits collapse into a single debounced write")
    func rapidEditsCollapseIntoOneWrite() async throws {
        let spy = ScreenplayRepositorySpy()
        let (sut, _) = makeSUT(
            character: Character(name: "Ripley"),
            repository: spy,
            debounce: .milliseconds(80)
        )

        // Several edits well within the debounce window — each cancels the prior
        // pending save, so only the final value should ever be written.
        sut.draft.intention = "A"
        sut.draft.intention = "AB"
        sut.draft.intention = "ABC"
        sut.draft.intention = "Survive"

        try await Task.sleep(for: .milliseconds(300))

        #expect(spy.saveCharacterCallCount == 1)
        #expect(spy.savedCharacters.last?.intention == "Survive")
    }
}
