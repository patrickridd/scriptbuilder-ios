import Testing
import Foundation
import Domain
@testable import FirebaseData

/// Regression suite for the "scenes don't save" bug.
///
/// An earlier build wrote scenes to the sibling node `actOneScenes/{id}` while
/// `ScreenplayDTO` read them from `actOne/scenes/{id}`. Every write succeeded,
/// but nothing ever came back on reload. These tests pin the write path to
/// the read path, and cover the rescue of scenes stranded in the stray node.
@Suite("Scene persistence paths")
struct ScenePersistencePathTests {

    private let allActs: [Act] = [.one, .two, .three]

    // MARK: - Helpers

    /// Builds the RTDB-shaped JSON of a scene, as the repository writes it.
    private func sceneJSON(uuid: String, title: String, number: Int = 1) -> [String: Any] {
        [
            "uuid": uuid, "header": "INT. VAULT - NIGHT", "title": title,
            "sceneNumber": number, "sceneDescription": "", "dialogue": "",
            "action": "", "characters": "", "howPushesStory": "", "notes": ""
        ]
    }

    /// Wraps `value` in nested dictionaries following a "/"-separated path,
    /// exactly as RTDB stores a multi-path `updateChildValues` write.
    private func nest(_ value: Any, at path: String) -> [String: Any] {
        let keys = path.split(separator: "/").map(String.init)
        var node: Any = value
        for key in keys.reversed() {
            node = [key: node]
        }
        return node as? [String: Any] ?? [:]
    }

    /// Deep-merges two RTDB-shaped dictionaries.
    private func merge(_ base: [String: Any], _ overlay: [String: Any]) -> [String: Any] {
        var result = base
        for (key, value) in overlay {
            if let existing = result[key] as? [String: Any], let incoming = value as? [String: Any] {
                result[key] = merge(existing, incoming)
            } else {
                result[key] = value
            }
        }
        return result
    }

    /// Reads the value stored at a "/"-separated path, or nil if any hop is missing.
    private func value(at path: String, in tree: [String: Any]) -> Any? {
        var node: Any? = tree
        for key in path.split(separator: "/").map(String.init) {
            node = (node as? [String: Any])?[key]
        }
        return node
    }

    private func decode(_ tree: [String: Any]) throws -> Screenplay {
        let data = try JSONSerialization.data(withJSONObject: tree)
        return try JSONDecoder().decode(ScreenplayDTO.self, from: data).toDomain()
    }

    private func encode(_ screenplay: Screenplay) throws -> [String: Any] {
        let data = try JSONEncoder().encode(ScreenplayDTO(domain: screenplay))
        let object = try JSONSerialization.jsonObject(with: data)
        return object as? [String: Any] ?? [:]
    }

    private func scenes(in act: Act, of screenplay: Screenplay) -> [Scene] {
        switch act {
        case .one:   return screenplay.act1.scenes
        case .two:   return screenplay.act2.scenes
        case .three: return screenplay.act3.scenes
        }
    }

    // MARK: - Write path == read path

    @Test("Scene writes target the nested act node, never the sibling node")
    func writePathIsNestedUnderAct() {
        #expect(RTDBPaths.relativeSceneKeyPath(act: .one, sceneKey: "scene-1") == "actOne/scenes/scene-1")
        #expect(RTDBPaths.relativeSceneKeyPath(act: .two, sceneKey: "scene-1") == "actTwo/scenes/scene-1")
        #expect(RTDBPaths.relativeSceneKeyPath(act: .three, sceneKey: "scene-1") == "actThree/scenes/scene-1")
    }

    @Test("A scene written at the write path is read back into the same act", arguments: [Act.one, .two, .three])
    func sceneAtWritePathIsReadBack(act: Act) throws {
        let path = RTDBPaths.relativeSceneKeyPath(act: act, sceneKey: "scene-42")
        let written = nest(sceneJSON(uuid: "scene-42", title: "The heist"), at: path)
        let tree = merge(["uuid": "sp-1", "title": "The Vault Gambit"], written)

        let screenplay = try decode(tree)

        let restored = scenes(in: act, of: screenplay).first { $0.uuid == "scene-42" }
        #expect(restored?.title == "The heist")
        for otherAct in allActs where otherAct != act {
            #expect(scenes(in: otherAct, of: screenplay).isEmpty)
        }
    }

    @Test("A full-screenplay save stores each scene exactly at its write path")
    func fullSaveMatchesWritePath() throws {
        var screenplay = Screenplay(uuid: "sp-1", title: "The Vault Gambit")
        screenplay.act1.scenes = [Scene(uuid: "opening", title: "Opening", sceneNumber: 1)]
        screenplay.act2.scenes = [Scene(uuid: "heist", title: "Heist", sceneNumber: 1)]
        screenplay.act3.scenes = [Scene(uuid: "escape", title: "Escape", sceneNumber: 1)]

        let tree = try encode(screenplay)

        let expected: [(act: Act, uuid: String, title: String)] = [
            (.one, "opening", "Opening"), (.two, "heist", "Heist"), (.three, "escape", "Escape")
        ]
        for entry in expected {
            let path = RTDBPaths.relativeSceneKeyPath(act: entry.act, sceneKey: entry.uuid)
            let stored = value(at: path, in: tree) as? [String: Any]
            #expect(stored?["title"] as? String == entry.title, "Missing scene at \(path)")
        }
    }

    @Test("Saving never writes the stray sibling scene nodes")
    func fullSaveNeverWritesStrayNodes() throws {
        var screenplay = Screenplay(uuid: "sp-1", title: "The Vault Gambit")
        screenplay.act1.scenes = [Scene(uuid: "opening", title: "Opening", sceneNumber: 1)]

        let tree = try encode(screenplay)

        for act in allActs {
            #expect(tree[act.scenesNodeKey] == nil, "\(act.scenesNodeKey) must never be encoded")
        }
    }

    @Test("Every scene field survives a save → load round trip")
    func sceneFieldsRoundTrip() throws {
        var screenplay = Screenplay(uuid: "sp-1", title: "The Vault Gambit")
        let original = Scene(
            uuid: "heist", title: "Heist", sceneNumber: 3,
            header: "INT. VAULT - NIGHT", sceneDescription: "They break in.",
            dialogue: "Now.", action: "Lights cut out.", characters: "Ripley, Ash",
            howPushesStory: "Point of no return.", notes: "Keep it silent."
        )
        screenplay.act2.scenes = [original]

        let restored = try decode(try encode(screenplay)).act2.scenes.first

        #expect(restored?.title == original.title)
        #expect(restored?.sceneNumber == original.sceneNumber)
        #expect(restored?.header == original.header)
        #expect(restored?.sceneDescription == original.sceneDescription)
        #expect(restored?.dialogue == original.dialogue)
        #expect(restored?.action == original.action)
        #expect(restored?.characters == original.characters)
        #expect(restored?.howPushesStory == original.howPushesStory)
        #expect(restored?.notes == original.notes)
    }

    // MARK: - Stray-node rescue

    @Test("The stray cleanup path points at the old sibling node, not the real one")
    func strayPathIsTheSiblingNode() {
        for act in allActs {
            let real = RTDBPaths.relativeSceneKeyPath(act: act, sceneKey: "scene-1")
            let stray = RTDBPaths.relativeStraySceneKeyPath(act: act, sceneKey: "scene-1")
            #expect(stray == "\(act.scenesNodeKey)/scene-1")
            #expect(stray != real)
        }
    }

    @Test("Scenes stranded in the stray node are rescued into their act", arguments: [Act.one, .two, .three])
    func strayScenesAreRescued(act: Act) throws {
        let path = RTDBPaths.relativeStraySceneKeyPath(act: act, sceneKey: "lost")
        let tree = merge(["uuid": "sp-1", "title": "T"], nest(sceneJSON(uuid: "lost", title: "Lost scene"), at: path))

        let screenplay = try decode(tree)

        #expect(scenes(in: act, of: screenplay).contains { $0.uuid == "lost" && $0.title == "Lost scene" })
    }

    @Test("A stray copy wins over the nested copy with the same id")
    func strayCopyWinsOnSameID() throws {
        let nested = nest(
            sceneJSON(uuid: "heist", title: "Old title"),
            at: RTDBPaths.relativeSceneKeyPath(act: .two, sceneKey: "heist")
        )
        let stray = nest(
            sceneJSON(uuid: "heist", title: "Newer title"),
            at: RTDBPaths.relativeStraySceneKeyPath(act: .two, sceneKey: "heist")
        )
        let tree = merge(merge(["uuid": "sp-1", "title": "T"], nested), stray)

        let actTwo = try decode(tree).act2.scenes

        #expect(actTwo.filter { $0.uuid == "heist" }.count == 1)
        #expect(actTwo.first { $0.uuid == "heist" }?.title == "Newer title")
    }

    @Test("Stray and nested scenes with different ids are both kept")
    func strayAndNestedScenesCoexist() throws {
        let nested = nest(
            sceneJSON(uuid: "opening", title: "Opening", number: 1),
            at: RTDBPaths.relativeSceneKeyPath(act: .one, sceneKey: "opening")
        )
        let stray = nest(
            sceneJSON(uuid: "meet-cute", title: "Meet cute", number: 2),
            at: RTDBPaths.relativeStraySceneKeyPath(act: .one, sceneKey: "meet-cute")
        )
        let tree = merge(merge(["uuid": "sp-1", "title": "T"], nested), stray)

        let identifiers = Set(try decode(tree).act1.scenes.map(\.uuid))

        #expect(identifiers == ["opening", "meet-cute"])
    }
}
