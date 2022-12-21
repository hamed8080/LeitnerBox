//
// ReviewViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

@testable import LeitnerBox
import SwiftUI
import XCTest
import AVFoundation

final class ReviewViewModelTests: XCTestCase {
    var viewModel: ReviewViewModel!

    override func setUp() async throws {
        await PersistenceController.shared.generateAndFillLeitner()
        let leitner = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext).leitners.first!
        let level = LevelsViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner).levels.first(where: { $0.level == 1 })!
        viewModel = ReviewViewModel(viewContext: PersistenceController.shared.viewContext, level: level, voiceSpeech: AVSpeechSynthesisVoice.speechVoices().first!)
    }

    func test_delete_question() {
        let question = viewModel.questions.first!
        viewModel.toggleDeleteDialog()
        XCTAssertEqual(viewModel.showDelete, true)

        viewModel.selectedQuestion = question
        viewModel.deleteQuestion()
        XCTAssertEqual(viewModel.showDelete, false)
        XCTAssertFalse(viewModel.questions.contains(where: { $0.objectID == question.objectID }))

        let lastQuestion = viewModel.questions.last!
        viewModel.questions.removeAll()
        viewModel.toggleDeleteDialog()
        viewModel.selectedQuestion = lastQuestion
        viewModel.deleteQuestion()
        XCTAssertEqual(viewModel.showDelete, false)
        XCTAssertTrue(viewModel.isFinished)
    }

    func test_toggle_favorite() {
        let question = viewModel.questions.first
        let beforeState = question?.favorite
        viewModel.selectedQuestion = question
        viewModel.toggleFavorite()
        let updated = viewModel.questions.first(where: { $0.objectID == question?.objectID })
        XCTAssertNotEqual(updated?.favorite, beforeState, "toggle favorite not worked!")
    }

    func test_pass_tapped() {
        let beforeQuestion = viewModel.questions.first
        let beforeDate = beforeQuestion?.passTime
        let beforePassCount = viewModel.passCount
        viewModel.selectedQuestion = beforeQuestion
        viewModel.pass()
        XCTAssertNotEqual(viewModel.selectedQuestion, beforeQuestion)
        XCTAssertEqual(viewModel.passCount, beforePassCount + 1)
        XCTAssertFalse(viewModel.isShowingAnswer)
        let leitner = beforeQuestion?.level?.leitner
        let updated = leitner?.findQuestion(objectID: beforeQuestion?.objectID)
        XCTAssertGreaterThan(updated?.passTime?.timeIntervalSince1970 ?? -1, beforeDate?.timeIntervalSince1970 ?? -1)

        let lastLevel = viewModel.level.leitner?.levels.first(where: { $0.level == 13 })
        let completedQuestion = viewModel.questions.first!
        completedQuestion.level = lastLevel
        viewModel.selectedQuestion = completedQuestion
        viewModel.pass()

        let fetchAgainCompleted = lastLevel?.allQuestions.first(where: { $0.objectID == completedQuestion.objectID })
        XCTAssertEqual(fetchAgainCompleted?.completed ?? false, true)

        let lastQuestion = viewModel.questions.last
        viewModel.selectedQuestion = lastQuestion
        viewModel.questions.removeAll()
        XCTAssertEqual(viewModel.hasNext, false)
        viewModel.pass()
        XCTAssertEqual(viewModel.isFinished, true)
    }

    func test_fail_tapped() {
        let beforeQuestion = viewModel.questions.first
        let beforeDate = beforeQuestion?.passTime
        let beforePassCount = viewModel.passCount
        let newStateOfQuestion = viewModel.level.leitner?.findQuestion(objectID: beforeQuestion?.objectID)
        viewModel.selectedQuestion = beforeQuestion
        viewModel.fail()
        XCTAssertNotEqual(viewModel.selectedQuestion, beforeQuestion)
        XCTAssertEqual(viewModel.failedCount, beforePassCount + 1)
        XCTAssertFalse(viewModel.isShowingAnswer)
        XCTAssertEqual(newStateOfQuestion?.level?.level, newStateOfQuestion?.level?.level)
        XCTAssertEqual(newStateOfQuestion?.passTime?.timeIntervalSince1970 ?? -1, beforeDate?.timeIntervalSince1970 ?? -1)

        viewModel.level.leitner?.backToTopLevel = true
        let questionToBackTop = viewModel.level.leitner?.allQuestions.first(where: { $0.level?.level ?? 0 > 1 })
        viewModel.selectedQuestion = questionToBackTop
        viewModel.fail()
        let newStateOfQuestionTop = viewModel.level.leitner?.findQuestion(objectID: questionToBackTop?.objectID)
        XCTAssertEqual(newStateOfQuestionTop?.level?.level, 1)

        let lastQuestion = viewModel.questions.last
        viewModel.selectedQuestion = lastQuestion
        viewModel.questions.removeAll()
        XCTAssertEqual(viewModel.hasNext, false)
        viewModel.fail()
        XCTAssertEqual(viewModel.isFinished, true)
    }

    func test_add_tag_to_question() {
        let beforeQuestion = viewModel.questions.first
        let tag = viewModel.level.leitner!.tagsArray.first!
        viewModel.selectedQuestion = beforeQuestion
        viewModel.addTagToQuestion(tag)
        let after = viewModel.level.leitner?.tagsArray.first(where: { $0.objectID == tag.objectID })
        let question = after?.questions.first(where: { $0.objectID == beforeQuestion?.objectID })
        XCTAssertNotNil(question)
    }

    func test_remove_tag_for_question() {
        let beforeQuestion = viewModel.questions.first
        XCTAssertNotNil(beforeQuestion)
        let tag = viewModel.level.leitner!.tagsArray.first!
        viewModel.selectedQuestion = beforeQuestion
        viewModel.removeTagForQuestion(tag)
        let after = viewModel.level.leitner?.tagsArray.first(where: { $0.objectID == tag.objectID })
        let question = after?.questions.first(where: { $0.objectID == beforeQuestion?.objectID })
        XCTAssertNil(question)
    }
}
