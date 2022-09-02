//
// ReviewViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class ReviewViewModelTests: XCTestCase {
    var vm: ReviewViewModel!

    override func setUp() {
        PersistenceController.generateAndFillLeitner()
        let leitner = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext).leitners.first!
        let level = LevelsViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner).levels.first(where: { $0.level == 1 })!
        vm = ReviewViewModel(viewContext: PersistenceController.preview.container.viewContext, level: level)
    }

    func test_delete_question() {
        let question = vm.questions.first!
        vm.toggleDeleteDialog()
        XCTAssertEqual(vm.showDelete, true)

        vm.selectedQuestion = question
        vm.deleteQuestion()
        XCTAssertEqual(vm.showDelete, false)
        XCTAssertFalse(vm.questions.contains(where: { $0.objectID == question.objectID }))

        let lastQuestion = vm.questions.last!
        vm.questions.removeAll()
        vm.toggleDeleteDialog()
        vm.selectedQuestion = lastQuestion
        vm.deleteQuestion()
        XCTAssertEqual(vm.showDelete, false)
        XCTAssertTrue(vm.isFinished)
    }

    func test_toggle_favorite() {
        let question = vm.questions.first
        let beforeState = question?.favorite
        vm.selectedQuestion = question
        vm.toggleFavorite()
        let updated = vm.questions.first(where: { $0.objectID == question?.objectID })
        XCTAssertNotEqual(updated?.favorite, beforeState, "toggle favorite not worked!")
    }

    func test_pass_tapped() {
        let beforeQuestion = vm.questions.first
        let beforeDate = beforeQuestion?.passTime
        let beforePassCount = vm.passCount
        vm.selectedQuestion = beforeQuestion
        vm.pass()
        XCTAssertNotEqual(vm.selectedQuestion, beforeQuestion)
        XCTAssertEqual(vm.passCount, beforePassCount + 1)
        XCTAssertFalse(vm.isShowingAnswer)
        let leitner = beforeQuestion?.level?.leitner
        let updated = leitner?.findQuestion(objectID: beforeQuestion?.objectID)
        XCTAssertGreaterThan(updated?.passTime?.timeIntervalSince1970 ?? -1, beforeDate?.timeIntervalSince1970 ?? -1)

        let lastLevel = vm.level.leitner?.levels.first(where: { $0.level == 13 })
        let completedQuestion = vm.questions.first!
        completedQuestion.level = lastLevel
        vm.selectedQuestion = completedQuestion
        vm.pass()

        let fetchAgainCompleted = lastLevel?.allQuestions.first(where: { $0.objectID == completedQuestion.objectID })
        XCTAssertEqual(fetchAgainCompleted?.completed ?? false, true)

        let lastQuestion = vm.questions.last
        vm.selectedQuestion = lastQuestion
        vm.questions.removeAll()
        XCTAssertEqual(vm.hasNext, false)
        vm.pass()
        XCTAssertEqual(vm.isFinished, true)
    }

    func test_fail_tapped() {
        let beforeQuestion = vm.questions.first
        let beforeDate = beforeQuestion?.passTime
        let beforePassCount = vm.passCount
        let newStateOfQuestion = vm.level.leitner?.findQuestion(objectID: beforeQuestion?.objectID)
        vm.selectedQuestion = beforeQuestion
        vm.fail()
        XCTAssertNotEqual(vm.selectedQuestion, beforeQuestion)
        XCTAssertEqual(vm.failedCount, beforePassCount + 1)
        XCTAssertFalse(vm.isShowingAnswer)
        XCTAssertEqual(newStateOfQuestion?.level?.level, newStateOfQuestion?.level?.level)
        XCTAssertEqual(newStateOfQuestion?.passTime?.timeIntervalSince1970 ?? -1, beforeDate?.timeIntervalSince1970 ?? -1)

        vm.level.leitner?.backToTopLevel = true
        let questionToBackTop = vm.level.leitner?.allQuestions.first(where: { $0.level?.level ?? 0 > 1 })
        vm.selectedQuestion = questionToBackTop
        vm.fail()
        let newStateOfQuestionTop = vm.level.leitner?.findQuestion(objectID: questionToBackTop?.objectID)
        XCTAssertEqual(newStateOfQuestionTop?.level?.level, 1)

        let lastQuestion = vm.questions.last
        vm.selectedQuestion = lastQuestion
        vm.questions.removeAll()
        XCTAssertEqual(vm.hasNext, false)
        vm.fail()
        XCTAssertEqual(vm.isFinished, true)
    }

    func test_add_tag_to_question() {
        let beforeQuestion = vm.questions.first
        let tag = vm.level.leitner!.tagsArray.first!
        vm.selectedQuestion = beforeQuestion
        vm.addTagToQuestion(tag)
        let after = vm.level.leitner?.tagsArray.first(where: { $0.objectID == tag.objectID })
        let question = after?.questions.first(where: { $0.objectID == beforeQuestion?.objectID })
        XCTAssertNotNil(question)
    }

    func test_remove_tag_for_question() {
        let beforeQuestion = vm.questions.first
        XCTAssertNotNil(beforeQuestion)
        let tag = vm.level.leitner!.tagsArray.first!
        vm.selectedQuestion = beforeQuestion
        vm.removeTagForQuestion(tag)
        let after = vm.level.leitner?.tagsArray.first(where: { $0.objectID == tag.objectID })
        let question = after?.questions.first(where: { $0.objectID == beforeQuestion?.objectID })
        XCTAssertNil(question)
    }
}
