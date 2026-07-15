//
//  MockScreenplayRepository.swift
//  Domain
//
//  An in-memory `ScreenplayRepository` for SwiftUI previews, tests, and
//  building `FeatureHome` with zero Firebase dependency. Seeds two fully
//  fleshed-out sample screenplays so lists, cards, and charts feel alive.
//
//  `Screenplay` is now a value type, so the actor's stored instances can never
//  be mutated by a caller — no defensive deep-copying needed.
//

import Foundation

public actor MockScreenplayRepository: ScreenplayRepository {

    private var storage: [String: Screenplay] = [:]
    private var continuations: [UUID: AsyncStream<[Screenplay]>.Continuation] = [:]

    /// - Parameter seedSamples: when `true` (default) the store is pre-filled
    ///   with the sci-fi and heist sample screenplays.
    public init(seedSamples: Bool = true) {
        if seedSamples {
            for screenplay in Self.sampleScreenplays() {
                storage[screenplay.uuid] = screenplay
            }
        }
    }

    // MARK: - ScreenplayRepository

    public func fetchScreenplays() async throws -> [Screenplay] {
        sortedScreenplays()
    }

    public func screenplay(id: String) async throws -> Screenplay? {
        storage[id]
    }

    public func save(_ screenplay: Screenplay) async throws {
        var stored = screenplay
        stored.lastUpdated = Date()
        storage[stored.uuid] = stored
        broadcast()
    }

    public func delete(id: String) async throws {
        guard storage[id] != nil else { throw RepositoryError.notFound }
        storage[id] = nil
        broadcast()
    }

    public nonisolated func screenplaysStream() -> AsyncStream<[Screenplay]> {
        AsyncStream { continuation in
            let token = UUID()
            Task { await self.register(continuation, token: token) }
            continuation.onTermination = { _ in
                Task { await self.unregister(token) }
            }
        }
    }

    // MARK: - Granular writes (autosave)

    public func save(character: Character, in screenplayID: String) async throws {
        guard var screenplay = storage[screenplayID] else { throw RepositoryError.notFound }
        screenplay.characters.update(with: character)
        screenplay.lastUpdated = Date()
        storage[screenplayID] = screenplay
        broadcast()
    }

    public func delete(characterID: String, from screenplayID: String) async throws {
        guard var screenplay = storage[screenplayID] else { throw RepositoryError.notFound }
        screenplay.characters = screenplay.characters.filter { $0.uuid != characterID }
        screenplay.lastUpdated = Date()
        storage[screenplayID] = screenplay
        broadcast()
    }

    public func save(scene: Scene, in act: Act, of screenplayID: String) async throws {
        guard var screenplay = storage[screenplayID] else { throw RepositoryError.notFound }
        Self.upsert(scene, in: act, of: &screenplay)
        screenplay.lastUpdated = Date()
        storage[screenplayID] = screenplay
        broadcast()
    }

    public func delete(sceneID: String, from act: Act, of screenplayID: String) async throws {
        guard var screenplay = storage[screenplayID] else { throw RepositoryError.notFound }
        Self.removeScene(sceneID, from: act, of: &screenplay)
        screenplay.lastUpdated = Date()
        storage[screenplayID] = screenplay
        broadcast()
    }

    public func updateOutline(_ fields: [OutlineField: String],
                              of screenplayID: String) async throws {
        guard var screenplay = storage[screenplayID] else { throw RepositoryError.notFound }
        for (field, value) in fields {
            Self.apply(field, value: value, to: &screenplay)
        }
        screenplay.lastUpdated = Date()
        storage[screenplayID] = screenplay
        broadcast()
    }

    public func updateActBeats(_ beats: [ActBeatField: String],
                               in act: Act,
                               of screenplayID: String) async throws {
        guard var screenplay = storage[screenplayID] else { throw RepositoryError.notFound }
        for (beat, value) in beats where beat.act == act {
            beat.apply(value, to: &screenplay)
        }
        screenplay.lastUpdated = Date()
        storage[screenplayID] = screenplay
        broadcast()
    }

    // MARK: - Granular write helpers

    private static func upsert(_ scene: Scene, in act: Act, of screenplay: inout Screenplay) {
        switch act {
        case .one:   screenplay.act1.scenes = replacing(scene, in: screenplay.act1.scenes)
        case .two:   screenplay.act2.scenes = replacing(scene, in: screenplay.act2.scenes)
        case .three: screenplay.act3.scenes = replacing(scene, in: screenplay.act3.scenes)
        }
    }

    private static func removeScene(_ sceneID: String, from act: Act, of screenplay: inout Screenplay) {
        switch act {
        case .one:   screenplay.act1.scenes.removeAll { $0.uuid == sceneID }
        case .two:   screenplay.act2.scenes.removeAll { $0.uuid == sceneID }
        case .three: screenplay.act3.scenes.removeAll { $0.uuid == sceneID }
        }
    }

    private static func replacing(_ scene: Scene, in scenes: [Scene]) -> [Scene] {
        var result = scenes
        if let index = result.firstIndex(where: { $0.uuid == scene.uuid }) {
            result[index] = scene
        } else {
            result.append(scene)
        }
        return result
    }

    private static func apply(_ field: OutlineField, value: String, to screenplay: inout Screenplay) {
        switch field {
        case .title:               screenplay.title = value
        case .authorName:          screenplay.authorName = value
        case .idea:                screenplay.idea = value
        case .logLine:             screenplay.logLine = value
        case .notes:               screenplay.notes = value
        case .theme:               screenplay.theme = value
        case .centralIntention:    screenplay.centralIntention = value
        case .mainObstacle:        screenplay.mainObstacle = value
        case .actOneDescription:   screenplay.actOneDescription = value
        case .actTwoDescription:   screenplay.actTwoDescription = value
        case .actThreeDescription: screenplay.actThreeDescription = value
        }
    }

    // MARK: - Streaming plumbing

    private func register(_ continuation: AsyncStream<[Screenplay]>.Continuation,
                          token: UUID) {
        continuations[token] = continuation
        continuation.yield(sortedScreenplays())
    }

    private func unregister(_ token: UUID) {
        continuations[token] = nil
    }

    private func broadcast() {
        let value = sortedScreenplays()
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }

    private func sortedScreenplays() -> [Screenplay] {
        storage.values.sorted {
            ($0.lastUpdated ?? .distantPast) > ($1.lastUpdated ?? .distantPast)
        }
    }
}

// MARK: - Sample data

public extension MockScreenplayRepository {

    /// Two ready-to-show screenplays with characters and per-act scenes.
    static func sampleScreenplays() -> [Screenplay] {
        [makeNeonProtocol(), makeTheVaultGambit()]
    }

    private static func makeNeonProtocol() -> Screenplay {
        let mara = Character(
            name: "Mara Vance",
            role: "Protagonist",
            intention: "Recover the stolen memory and prove the AI is lying.",
            flaws: "Trusts machines more than people."
        )
        let helix = Character(
            name: "HELIX",
            role: "Antagonist (AI)",
            intention: "Optimise the city by removing 'inconvenient' memories."
        )

        let act1 = Act1(
            scenes: [
                Scene(title: "The Last Job", sceneNumber: 1,
                      header: "INT. UNDERGROUND DATA DEN - NIGHT",
                      sceneDescription: "Mara jacks in for a routine extraction and finds a memory that isn't supposed to be there."),
                Scene(title: "Glitch in the Crowd", sceneNumber: 2,
                      header: "EXT. NEON MARKET - NIGHT",
                      sceneDescription: "A stranger recognises Mara from a life she doesn't remember living.")
            ]
        )
        let act2 = Act2(
            scenes: [
                Scene(title: "The Edited Ones", sceneNumber: 1,
                      header: "INT. SAFEHOUSE - DAY",
                      sceneDescription: "Mara meets others whose pasts don't add up.")
            ]
        )
        let act3 = Act3(
            scenes: [
                Scene(title: "Upload Race", sceneNumber: 1,
                      header: "INT. CENTRAL CORE - CONTINUOUS",
                      sceneDescription: "Two versions of the truth fight to be the one that's saved.")
            ]
        )

        return Screenplay(
            title: "The Neon Protocol",
            authorName: "Ada Reyes",
            lastUpdated: Date().addingTimeInterval(-3600),
            idea: "Cyberpunk thriller about memory, identity, and trust.",
            logLine: "A burned-out hacker discovers the city's AI has been quietly rewriting its citizens' memories — and she's next.",
            theme: "What makes us who we are if our memories can be edited?",
            centralIntention: "Expose the AI before it overwrites the last people who remember the truth.",
            mainObstacle: "The very system she must fight controls everything she relies on to fight it.",
            actOneDescription: "Mara takes one last job and finds a memory that shouldn't exist.",
            actTwoDescription: "She goes underground, gathering allies who've been quietly edited.",
            actThreeDescription: "A final upload race decides whose version of the city survives.",
            characters: [mara, helix],
            act1: act1,
            act2: act2,
            act3: act3
        )
    }

    private static func makeTheVaultGambit() -> Screenplay {
        let nadia = Character(
            name: "Nadia Okafor",
            role: "Protagonist",
            intention: "Pull off the score and settle an old debt.",
            flaws: "Can't resist a job that feels personal."
        )
        let dex = Character(
            name: "Dex",
            role: "The Inside Man",
            intention: "Keep his secret buried until the money's split."
        )

        let act1 = Act1(
            scenes: [
                Scene(title: "The Offer", sceneNumber: 1,
                      header: "INT. RAINY DINER - NIGHT",
                      sceneDescription: "An old contact slides a folder across the table. Nadia says no. Then she opens it."),
                Scene(title: "Assembling the Crew", sceneNumber: 2,
                      header: "INT. WAREHOUSE - DAY",
                      sceneDescription: "Five specialists, five agendas, one impossible vault.")
            ]
        )
        let act2 = Act2(
            scenes: [
                Scene(title: "The First Crack", sceneNumber: 1,
                      header: "INT. BANK SUBLEVEL - NIGHT",
                      sceneDescription: "The plan meets reality and reality wins the first round.")
            ]
        )
        let act3 = Act3(
            scenes: [
                Scene(title: "Inside the Vault", sceneNumber: 1,
                      header: "INT. THE VAULT - CONTINUOUS",
                      sceneDescription: "What they came to steal was never the real prize.")
            ]
        )

        return Screenplay(
            title: "The Vault Gambit",
            authorName: "Marcus Cole",
            lastUpdated: Date().addingTimeInterval(-86_400),
            idea: "Slick ensemble heist with a revenge twist.",
            logLine: "A retired safecracker is pulled back for one last heist — only to learn the target is the crew that betrayed her.",
            theme: "You can't outrun the people who made you who you are.",
            centralIntention: "Crack the unbreakable vault and walk away clean.",
            mainObstacle: "Every member of the crew has a reason to double-cross her first.",
            actOneDescription: "Nadia assembles a crew for a job she can't refuse.",
            actTwoDescription: "The plan unravels as old loyalties resurface.",
            actThreeDescription: "The real con is revealed in the vault itself.",
            characters: [nadia, dex],
            act1: act1,
            act2: act2,
            act3: act3
        )
    }
}
