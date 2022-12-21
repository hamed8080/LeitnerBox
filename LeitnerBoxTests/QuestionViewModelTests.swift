//
// QuestionViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class QuestionViewModelTests: XCTestCase {
    var viewModel: QuestionViewModel!

    override func setUp() async throws {
        await PersistenceController.shared.generateAndFillLeitner()
        let viewContext = PersistenceController.shared.viewContext
        let leitner = LeitnerViewModel(viewContext: viewContext).leitners.first!
        let question = Question(context: viewContext)
        question.level = leitner.firstLevel
        self.viewModel = QuestionViewModel(viewContext: viewContext, leitner: leitner, question: question)
    }

    func test_save_edit() async {
        let question = viewModel.level.allQuestions.first!
        viewModel.question = question
        viewModel.saveEdit()
        XCTAssertEqual(question.completed, viewModel.completed)
        XCTAssertEqual(question.answer, viewModel.answer)
        XCTAssertEqual(question.question, viewModel.questionString)
        XCTAssertEqual(question.detailDescription, viewModel.detailDescription)
        XCTAssertEqual(question.favorite, viewModel.favorite)

        let questionWithFav = viewModel.level.allQuestions.first!
        viewModel.question = questionWithFav
        viewModel.favorite = true
        viewModel.saveEdit()
        XCTAssertEqual(questionWithFav.favorite, true)
    }

    func test_insert() {
        viewModel.questionString = "New Question"
        viewModel.answer = "Answer"
        viewModel.detailDescription = "Descrition"
        viewModel.completed = true
        viewModel.favorite = true
        viewModel.insert()
        let question = viewModel.level.leitner?.allQuestions.first(where: { $0.question == "New Question" })
        XCTAssertEqual(question?.completed, true)
        XCTAssertTrue(question?.answer == "Answer")
        XCTAssertTrue(question?.question == "New Question")
        XCTAssertTrue(question?.detailDescription == "Descrition")
        XCTAssertEqual(question?.favorite, true)
        XCTAssertEqual(question?.level?.level, 13)

        viewModel.completed = false
        viewModel.questionString = "TestNewQuestionCompletedFalse"
        viewModel.insert()
        let notCompletedQuestion = viewModel.level.leitner?.allQuestions.first(where: { $0.question == "TestNewQuestionCompletedFalse" })
        XCTAssertEqual(notCompletedQuestion?.completed, false)
        XCTAssertEqual(notCompletedQuestion?.level?.level, 1)
    }

    func test_save() {
        let viewContext = PersistenceController.shared.viewContext
        let leitner = LeitnerViewModel(viewContext: viewContext).leitners.first!
        viewModel = QuestionViewModel(viewContext: viewContext, leitner: leitner, question: nil)
        let insertObjectCount = viewContext.insertedObjects.count
        viewModel.answer = "New Question"
        viewModel.save()
        let afterSaveObjectCount = viewContext.insertedObjects.count
        XCTAssertNotEqual(insertObjectCount, afterSaveObjectCount, "Number of elements should not be equal after save the insertion.")
    }

    func test_save_update() {
        let question = viewModel.level.allQuestions.first!
        viewModel.question = question
        viewModel.answer = "Updated answer"
        viewModel.save()
        XCTAssertEqual(question.answer, "Updated answer")
    }

    func test_clear() {
        let question = viewModel.level.allQuestions.first!
        viewModel.questionString = "New Question"
        viewModel.answer = "Answer"
        viewModel.question = question
        viewModel.detailDescription = "Descrition"
        viewModel.clear()

        XCTAssertEqual(viewModel.isManual, true)
        XCTAssertEqual(viewModel.favorite, false)
        XCTAssertEqual(viewModel.completed, false)
        XCTAssertTrue(viewModel.answer == "")
        XCTAssertTrue(viewModel.questionString == "")
        XCTAssertTrue(viewModel.detailDescription == "")
    }

    override func tearDown() {
        viewModel = nil
    }
}
