//
// ReviewViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
@testable import LeitnerBox
import SwiftUI
import XCTest

final class ReviewViewModelTests: XCTestCase {
    var viewModel: ReviewViewModel!
    var mockContext: MockNSManagedObjectContext! = .init()

    override func setUp() {
        let leitner = ManagedObjectContextInstance.instance.leitners.first!
        let level = LevelsViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner).levels.first(where: { $0.level.level == 1 })!
        let mockSpeech = MockAVSpeechSynthesisVoice()
        let synthesizer = MockAVSpeechSynthesizer()
        viewModel = ReviewViewModel(viewContext: PersistenceController.shared.viewContext,
                                    levelValue: level.level.level,
                                    leitnerId: leitner.id,
                                    voiceSpeech: mockSpeech,
                                    synthesizer: synthesizer)
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

    func setSelectedQuestion() {
        let question = viewModel.questions.first
        viewModel.selectedQuestion = question
    }

    func test_passed_is_showing_false() {
        setSelectedQuestion()
        XCTAssertFalse(viewModel.isShowingAnswer)
    }

    func test_failed_is_showing_false() {
        setSelectedQuestion()
        viewModel.fail()
        XCTAssertFalse(viewModel.isShowingAnswer)
    }

    func test_failed_increase_fail_count() {
        let beforeFailCount = viewModel.failedCount
        setSelectedQuestion()
        viewModel.fail()
        XCTAssertGreaterThan(viewModel.failedCount, beforeFailCount)
    }

    func test_passed_increase_pass_count() {
        let beforePassCount = viewModel.passCount
        setSelectedQuestion()
        viewModel.pass()
        XCTAssertGreaterThan(viewModel.passCount, beforePassCount)
    }

    func test_passed_select_a_new_question() {
        setSelectedQuestion()
        let before = viewModel.selectedQuestion
        viewModel.pass()
        XCTAssertNotEqual(viewModel.selectedQuestion, before)
    }

    func test_failed_select_a_new_question() {
        setSelectedQuestion()
        let before = viewModel.selectedQuestion
        viewModel.fail()
        XCTAssertNotEqual(viewModel.selectedQuestion, before)
    }

    func test_failed_reset_level_if_back_to_top_is_enabled() {
        setSelectedQuestion()
        let question = viewModel.selectedQuestion
        viewModel.leitner?.backToTopLevel = true
        viewModel.save() // to save backToTopLevel change
        viewModel.fail()
        let updated = findQuestion(leitnerId: viewModel.leitner?.id, question: question, level: 1)
        XCTAssertNotNil(updated)
    }

    func test_failed_not_reset_level_if_back_to_top_is_not_enabled() {
        let question = findQuestion(leitnerId: viewModel.leitner?.id, level: 2)
        viewModel.selectedQuestion = question
        viewModel.leitner?.backToTopLevel = false
        viewModel.save() // to save backToTopLevel change
        viewModel.fail()
        let updated = findQuestion(leitnerId: viewModel.leitner?.id, question: question, level: 2)
        XCTAssertNotNil(updated)
    }

    func test_passed_question_in_last_level_set_completed() {
        let question = findQuestion(leitnerId: viewModel.leitner?.id, level: 13)
        viewModel.selectedQuestion = question
        viewModel.pass()
        let updated = findQuestion(leitnerId: viewModel.leitner?.id, question: question, level: 13)
        XCTAssertEqual(updated?.completed, true)
    }

    func test_passed_change_pass_time() {
        setSelectedQuestion()
        let question = viewModel.selectedQuestion
        let lastPastedTime = question?.passTime?.timeIntervalSince1970 ?? -1
        viewModel.pass()
        let updated = findQuestion(leitnerId: viewModel.leitner?.id, question: question, level: 2)
        XCTAssertGreaterThan(updated?.passTime?.timeIntervalSince1970 ?? -1, lastPastedTime)
    }

    func test_failed_do_not_change_pass_time() {
        setSelectedQuestion()
        let question = viewModel.selectedQuestion
        let lastPastedTime = question?.passTime?.timeIntervalSince1970 ?? -1
        viewModel.fail()
        let updated = findQuestion(leitnerId: viewModel.leitner?.id, question: question, level: 1)
        XCTAssertEqual(updated?.passTime?.timeIntervalSince1970 ?? -1, lastPastedTime)
    }

    func test_failed_has_next() {
        setSelectedQuestion()
        viewModel.fail()
        XCTAssertTrue(viewModel.hasNext)
        XCTAssertFalse(viewModel.isFinished)
    }

    func test_failed_has_not_next() {
        setSelectedQuestion()
        viewModel.questions.removeAll()
        viewModel.fail()
        XCTAssertFalse(viewModel.hasNext)
        XCTAssertTrue(viewModel.isFinished)
    }

    func test_passed_has_next() {
        setSelectedQuestion()
        viewModel.pass()
        XCTAssertTrue(viewModel.hasNext)
        XCTAssertFalse(viewModel.isFinished)
    }

    func test_passed_has_not_next() {
        setSelectedQuestion()
        viewModel.questions.removeAll()
        viewModel.pass()
        XCTAssertFalse(viewModel.hasNext)
        XCTAssertTrue(viewModel.isFinished)
    }

    func findQuestion(leitnerId: Int64?, question: Question?, level: Int64, completed: Bool) -> Question? {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "question == %@ AND leitnerId == %i AND levelValue == %i AND completed == %@", question?.question ?? "", leitnerId ?? -1, level, NSNumber(booleanLiteral: completed))
        let dbQuestions = try? viewModel.viewContext.fetch(req)
        return dbQuestions?.first
    }

    func findQuestion(leitnerId: Int64?, level: Int, completed: Bool = false) -> Question? {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "leitnerId == %i AND levelValue == %i AND completed == %@", leitnerId ?? -1, level, NSNumber(booleanLiteral: completed))
        let dbQuestions = try? viewModel.viewContext.fetch(req)
        return dbQuestions?.first
    }

    func findQuestion(leitnerId: Int64?, question: Question?, level: Int) -> Question? {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "question == %@ AND leitnerId == %i AND levelValue == %i", question?.question ?? "", leitnerId ?? -1, level)
        let dbQuestions = try? viewModel.viewContext.fetch(req)
        return dbQuestions?.first
    }

    override func tearDown() {
        viewModel = nil
    }
}
