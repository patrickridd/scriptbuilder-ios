//
//  ArcQuestionPersistenceTests.swift
//  FirebaseDataTests
//
//  Custom arc questions, saved order and disabled stock questions survive
//  the CharacterDTO round trip, and odd stored data never drops the rest.
//

import XCTest
import Domain
@testable import FirebaseData

final class ArcQuestionPersistenceTests: XCTestCase {

    func testArcCustomisationRoundTripsThroughDTO() throws {
        var hero = Character(name: "Ripley")
        var question = hero.insertArcQuestion(after: .template(.flaws))
        question.title = "What does she owe Newt?"
        question.text = "Everything"
        hero.upsert(arcQuestion: question)
        hero.moveArcQuestion(.template(.need), by: -7)
        hero.setArcQuestion(.whatToDo, disabled: true)

        let data = try JSONEncoder().encode(CharacterDTO(domain: hero))
        let restored = try JSONDecoder().decode(CharacterDTO.self, from: data).toDomain()

        XCTAssertEqual(restored.arcQuestions, hero.arcQuestions)
        XCTAssertEqual(restored.savedArcOrder, hero.savedArcOrder)
        XCTAssertEqual(restored.disabledArcQuestions, [.whatToDo])
        XCTAssertEqual(restored.arcOrder, hero.arcOrder)
    }

    func testStandardCharacterWritesNoArcKeys() throws {
        let data = try JSONEncoder().encode(CharacterDTO(domain: Character(name: "Ripley")))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNil(json["arcQuestions"])
        XCTAssertNil(json["arcOrder"])
        XCTAssertNil(json["disabledArcQuestions"])
    }

    func testOddStoredDataKeepsEverythingElse() throws {
        let json = #"""
        {"uuid":"c1","name":"Ripley","intention":"Survive",
         "arcQuestions":{"q1":{"title":"Why Newt?","order":"2"},"q2":"garbage"},
         "arcOrder":"template:need/custom:q1/template:retired",
         "disabledArcQuestions":{"flaws":true,"obstacles":false,"retired":true}}
        """#
        let character = try JSONDecoder().decode(CharacterDTO.self, from: Data(json.utf8)).toDomain()

        XCTAssertEqual(character.intention, "Survive")
        XCTAssertEqual(character.arcQuestions.map(\.id), ["q1"])
        XCTAssertEqual(character.arcQuestions.first?.order, 2)
        XCTAssertEqual(character.savedArcOrder, [.template(.need), .custom("q1")])
        XCTAssertEqual(character.disabledArcQuestions, [.flaws])
        XCTAssertEqual(character.arcOrder.first, .template(.need))
    }
}
