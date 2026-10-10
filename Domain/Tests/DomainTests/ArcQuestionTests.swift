//
//  ArcQuestionTests.swift
//  DomainTests
//
//  Ordering, progress, insert/delete and moves for a character's arc
//  questions, plus backward-compatible decoding of older characters.
//

import Foundation
import Testing
@testable import Domain

@Suite("Arc questions")
struct ArcQuestionTests {

    private let stock = ArcTemplateQuestion.allCases.map(ArcQuestionRef.template)

    @Test("Characters saved before arc questions existed still decode")
    func legacyCharacterDecodes() throws {
        let json = #"{"uuid":"c1","name":"Ripley","intention":"Survive"}"#
        let character = try JSONDecoder().decode(Character.self, from: Data(json.utf8))
        #expect(character.arcQuestions.isEmpty)
        #expect(character.savedArcOrder == nil)
        #expect(character.disabledArcQuestions.isEmpty)
        #expect(character.arcOrder == stock)
    }

    @Test("A fresh character shows the nine stock questions in standard order")
    func standardOrder() {
        let character = Character(name: "Ripley")
        #expect(character.arcSlots.map(\.ref) == stock)
        #expect(character.isUsingStandardArcOrder)
        #expect(character.arcTotalCount == 9)
    }

    @Test("Insert after a stock question lands directly after it")
    func insertAfterTemplate() {
        var character = Character(name: "Ripley")
        let first = character.insertArcQuestion(after: .template(.flaws))
        let second = character.insertArcQuestion(after: .template(.flaws))
        let order = character.arcOrder
        let flawsIndex = order.firstIndex(of: .template(.flaws)) ?? -1
        #expect(order[flawsIndex + 1] == .custom(second.id))
        #expect(order[flawsIndex + 2] == .custom(first.id))
        #expect(character.savedArcOrder == nil)
    }

    @Test("Insert after a custom question lands between it and its next sibling")
    func insertAfterCustom() {
        var character = Character(name: "Ripley")
        let first = character.insertArcQuestion(after: .template(.need))
        let later = character.insertArcQuestion(after: .custom(first.id))
        let middle = character.insertArcQuestion(after: .custom(first.id))
        let customs = character.arcOrder.filter { if case .custom = $0 { return true } else { return false } }
        #expect(customs == [.custom(first.id), .custom(middle.id), .custom(later.id)])
    }

    @Test("Custom questions count toward progress; disabled stock ones don't")
    func progress() {
        var character = Character(name: "Ripley", intention: "Survive")
        var question = character.insertArcQuestion(after: nil)
        #expect(character.arcTotalCount == 10)
        #expect(character.arcFilledCount == 1)
        question.text = "Her daughter"
        character.upsert(arcQuestion: question)
        character.setArcQuestion(.whatToDo, disabled: true)
        #expect(character.arcTotalCount == 9)
        #expect(character.arcFilledCount == 2)
        #expect(character.firstUnfilledArcSlot == .template(.whyIntention))
    }

    @Test("A character with no arc counts as complete")
    func waivedArcIsComplete() {
        var character = Character(name: "The Iceberg", arcNotApplicable: true)
        character.insertArcQuestion(after: nil)
        #expect(character.arcFilledCount == character.arcTotalCount)
        #expect(character.firstUnfilledArcSlot == nil)
    }

    @Test("Move down then up returns to standard order and clears the saved order")
    func moveRoundTrip() {
        var character = Character(name: "Ripley")
        character.moveArcQuestion(.template(.intention), by: 1)
        #expect(character.arcOrder.first == .template(.whyIntention))
        #expect(character.savedArcOrder != nil)
        character.moveArcQuestion(.template(.intention), by: -1)
        #expect(character.savedArcOrder == nil)
        #expect(!character.canMoveArcQuestion(.template(.intention), by: -1))
    }

    @Test("Inserting into a rearranged list pins the question at that spot")
    func insertIntoSavedOrder() {
        var character = Character(name: "Ripley")
        character.moveArcQuestion(.template(.need), by: -7)
        let question = character.insertArcQuestion(after: .template(.need))
        let order = character.arcOrder
        let needIndex = order.firstIndex(of: .template(.need)) ?? -1
        #expect(order[needIndex + 1] == .custom(question.id))
        #expect(character.savedArcOrder?.contains(.custom(question.id)) == true)
    }

    @Test("A stale saved order is repaired on read")
    func repairsSavedOrder() {
        var character = Character(name: "Ripley")
        let question = character.insertArcQuestion(after: .template(.obstacles))
        // Saved on another device before the custom question existed, with a
        // deleted question and a duplicate thrown in.
        let others = stock.filter { $0 != .template(.need) }
        character.savedArcOrder = [.template(.need), .custom("ghost")] + others + [.template(.need)]
        let order = character.arcOrder
        #expect(order.first == .template(.need))
        #expect(Set(order) == Set(stock + [.custom(question.id)]))
        #expect(order.count == stock.count + 1)
        let obstaclesIndex = order.firstIndex(of: .template(.obstacles)) ?? -1
        #expect(order[obstaclesIndex + 1] == .custom(question.id))
    }

    @Test("Deleting a question strips it from the saved order; reset keeps it")
    func deleteAndReset() {
        var character = Character(name: "Ripley")
        let kept = character.insertArcQuestion(after: nil)
        let doomed = character.insertArcQuestion(after: nil)
        character.moveArcQuestion(.custom(kept.id), by: -9)
        #expect(character.arcOrder.first == .custom(kept.id))
        character.removeArcQuestion(id: doomed.id)
        #expect(character.savedArcOrder?.contains(.custom(doomed.id)) == false)
        character.resetArcOrder()
        #expect(character.isUsingStandardArcOrder)
        #expect(character.arcOrder.last == .custom(kept.id))
    }

    @Test("Refs survive the joined storage string")
    func refStorageRoundTrip() {
        let refs: [ArcQuestionRef] = [.template(.need), .custom("abc"), .template(.intention)]
        #expect(ArcQuestionRef.split(ArcQuestionRef.joined(refs)) == refs)
        #expect(ArcQuestionRef.split("template:retired/custom:x") == [.custom("x")])
    }
}
