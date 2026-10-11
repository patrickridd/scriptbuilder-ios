//
//  Character+ArcQuestions.swift
//  Domain
//
//  Ordering, progress, editing and moves for a character's arc questions.
//  Single source of truth for "what does the arc list look like" so the arc
//  screen, progress badges and exports can never disagree.
//

import Foundation

// MARK: - Stock answers

public extension Character {

    /// The writer's answer to a stock question.
    func text(for question: ArcTemplateQuestion) -> String {
        switch question {
        case .intention: return intention
        case .whyIntention: return whyIntention
        case .whatToDo: return whatToDo
        case .howDoesCharacterDoIt: return howDoesCharacterDoIt
        case .obstacles: return obstacles
        case .flaws: return flaws
        case .intentionFix: return intentionFix
        case .need: return need
        case .howCharacterChanged: return howCharacterChanged
        }
    }

    mutating func setText(_ newValue: String, for question: ArcTemplateQuestion) {
        switch question {
        case .intention: intention = newValue
        case .whyIntention: whyIntention = newValue
        case .whatToDo: whatToDo = newValue
        case .howDoesCharacterDoIt: howDoesCharacterDoIt = newValue
        case .obstacles: obstacles = newValue
        case .flaws: flaws = newValue
        case .intentionFix: intentionFix = newValue
        case .need: need = newValue
        case .howCharacterChanged: howCharacterChanged = newValue
        }
    }
}

// MARK: - Ordering

public extension Character {

    /// Stock questions in standard order, each followed by the custom
    /// questions anchored to it; unanchored custom questions go last.
    var standardArcOrder: [ArcQuestionRef] {
        let sorted = arcQuestions.sorted { lhs, rhs in
            lhs.order == rhs.order ? lhs.id < rhs.id : lhs.order < rhs.order
        }
        var byAnchor: [ArcTemplateQuestion: [ArcQuestion]] = [:]
        var trailing: [ArcQuestion] = []
        for question in sorted {
            if let anchor = question.anchor {
                byAnchor[anchor, default: []].append(question)
            } else {
                trailing.append(question)
            }
        }
        var refs: [ArcQuestionRef] = []
        for template in ArcTemplateQuestion.allCases {
            refs.append(.template(template))
            refs += (byAnchor[template] ?? []).map { .custom($0.id) }
        }
        refs += trailing.map { .custom($0.id) }
        return refs
    }

    /// The order to display. A saved order is **repaired on read**: unknown
    /// or duplicate refs are dropped, and anything missing (a question added
    /// on another device, a new stock question) is slotted in right after
    /// its standard predecessor.
    var arcOrder: [ArcQuestionRef] {
        let standard = standardArcOrder
        guard let saved = savedArcOrder else { return standard }
        let valid = Set(standard)
        var seen: Set<ArcQuestionRef> = []
        var result = saved.filter { valid.contains($0) && seen.insert($0).inserted }
        var predecessor: ArcQuestionRef?
        for ref in standard {
            if !seen.contains(ref) {
                let index = predecessor.flatMap { result.firstIndex(of: $0) }.map { $0 + 1 } ?? 0
                result.insert(ref, at: index)
                seen.insert(ref)
            }
            predecessor = ref
        }
        return result
    }

    /// The arc list resolved to slots, in display order. Disabled stock
    /// questions are included (the screen shows them faded with "Enable").
    var arcSlots: [ArcSlot] {
        arcOrder.compactMap { ref in
            switch ref {
            case .template(let question): return .template(question)
            case .custom(let id): return arcQuestion(withID: id).map(ArcSlot.custom)
            }
        }
    }

    func arcQuestion(withID id: String) -> ArcQuestion? {
        arcQuestions.first { $0.id == id }
    }

    func isArcQuestionDisabled(_ question: ArcTemplateQuestion) -> Bool {
        disabledArcQuestions.contains(question)
    }

    mutating func setArcQuestion(_ question: ArcTemplateQuestion, disabled: Bool) {
        if disabled {
            disabledArcQuestions.insert(question)
        } else {
            disabledArcQuestions.remove(question)
        }
    }
}

// MARK: - Progress

public extension Character {

    /// Slots that count toward progress: every custom question plus the
    /// stock questions that are switched on.
    var activeArcSlots: [ArcSlot] {
        arcSlots.filter { slot in
            if case .template(let question) = slot { return !isArcQuestionDisabled(question) }
            return true
        }
    }

    var arcTotalCount: Int { activeArcSlots.count }

    /// A character marked as having no arc counts as fully done — the
    /// decision *is* the work.
    var arcFilledCount: Int {
        guard !arcNotApplicable else { return arcTotalCount }
        return activeArcSlots.filter(isFilled).count
    }

    /// Drives the "Next up: …" nudge.
    var firstUnfilledArcSlot: ArcSlot? {
        guard !arcNotApplicable else { return nil }
        return activeArcSlots.first { !isFilled($0) }
    }

    private func isFilled(_ slot: ArcSlot) -> Bool {
        switch slot {
        case .template(let question):
            return !text(for: question).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .custom(let question):
            return question.isFilled
        }
    }
}

// MARK: - Editing

public extension Character {

    /// Inserts or replaces (by `id`) a custom question.
    mutating func upsert(arcQuestion: ArcQuestion) {
        if let index = arcQuestions.firstIndex(where: { $0.id == arcQuestion.id }) {
            arcQuestions[index] = arcQuestion
        } else {
            arcQuestions.append(arcQuestion)
        }
    }

    /// Creates an empty custom question directly after `ref` (`nil` = end of
    /// the list) and returns it. In a rearranged list the new question is
    /// pinned into the saved order at that exact spot too.
    @discardableResult
    mutating func insertArcQuestion(after ref: ArcQuestionRef?) -> ArcQuestion {
        var question = ArcQuestion()
        switch ref {
        case .none:
            question.anchor = nil
            question.order = nextOrder(after: nil)
        case .template(let template):
            let siblings = arcQuestions.filter { $0.anchor == template }
            question.anchor = template
            question.order = (siblings.map(\.order).min() ?? 1) - 1
        case .custom(let id):
            let existing = arcQuestion(withID: id)
            question.anchor = existing?.anchor
            question.order = self.order(justAfter: existing)
        }
        let currentOrder = savedArcOrder == nil ? nil : arcOrder
        arcQuestions.append(question)
        if var order = currentOrder {
            let index = ref.flatMap { order.firstIndex(of: $0) }.map { $0 + 1 } ?? order.count
            order.insert(.custom(question.id), at: index)
            savedArcOrder = order
        }
        return question
    }

    /// Removes a custom question and strips it from any saved order.
    mutating func removeArcQuestion(id: String) {
        arcQuestions.removeAll { $0.id == id }
        savedArcOrder?.removeAll { $0 == .custom(id) }
    }

    private func nextOrder(after anchor: ArcTemplateQuestion?) -> Double {
        let siblings = arcQuestions.filter { $0.anchor == anchor }
        return (siblings.map(\.order).max() ?? -1) + 1
    }

    /// An `order` that lands just after `question` and before its next
    /// sibling (same anchor), without renumbering anyone.
    private func order(justAfter question: ArcQuestion?) -> Double {
        guard let question else { return nextOrder(after: nil) }
        let later = arcQuestions
            .filter { $0.anchor == question.anchor && $0.order > question.order }
            .map(\.order)
            .min()
        guard let later else { return question.order + 1 }
        return (question.order + later) / 2
    }
}

// MARK: - Moves

public extension Character {

    var isUsingStandardArcOrder: Bool { arcOrder == standardArcOrder }

    func canMoveArcQuestion(_ ref: ArcQuestionRef, by offset: Int) -> Bool {
        let order = arcOrder
        guard let index = order.firstIndex(of: ref) else { return false }
        return order.indices.contains(index + offset)
    }

    /// Moves one entry up (negative) or down (positive).
    mutating func moveArcQuestion(_ ref: ArcQuestionRef, by offset: Int) {
        var order = arcOrder
        guard let index = order.firstIndex(of: ref), order.indices.contains(index + offset) else { return }
        order.remove(at: index)
        order.insert(ref, at: index + offset)
        applyArcOrder(order)
    }

    /// Saves a full order. One that matches the standard order collapses to
    /// `nil`, so "rearranged" never sticks around after a no-op shuffle.
    mutating func applyArcOrder(_ refs: [ArcQuestionRef]) {
        savedArcOrder = refs == standardArcOrder ? nil : refs
    }

    /// Back to the standard order. Custom questions return to their anchors;
    /// nothing is deleted.
    mutating func resetArcOrder() {
        savedArcOrder = nil
    }
}
