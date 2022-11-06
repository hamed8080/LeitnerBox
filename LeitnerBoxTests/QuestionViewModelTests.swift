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

    override func setUp() {
        PersistenceController.generateAndFillLeitner()
        let viewContext = PersistenceController.shared.viewContext
        let leitner = LeitnerViewModel(viewContext: viewContext).leitners.first!
        let level = LevelsViewModel(viewContext: viewContext, leitner: leitner).levels.first(where: { $0.level == 1 })!
        viewModel = QuestionViewModel(viewContext: viewContext, level: level, question: Question(context: viewContext), isInEditMode: false)
    }

    func test_save_edit() {
        let question = viewModel.level.allQuestions.first!
        viewModel.question = question
        viewModel.saveEdit()
        XCTAssertEqual(question.completed, viewModel.isCompleted)
        XCTAssertEqual(question.answer, viewModel.answer)
        XCTAssertEqual(question.question, viewModel.questionString)
        XCTAssertEqual(question.detailDescription, viewModel.descriptionDetail)
        XCTAssertEqual(question.favorite, viewModel.isFavorite)

        let questionWithFav = viewModel.level.allQuestions.first!
        viewModel.question = questionWithFav
        viewModel.isFavorite = true
        viewModel.saveEdit()
        XCTAssertEqual(questionWithFav.favorite, true)
    }

    func test_insert() {
        viewModel.questionString = "New Question"
        viewModel.answer = "Answer"
        viewModel.descriptionDetail = "Descrition"
        viewModel.isCompleted = true
        viewModel.isFavorite = true
        viewModel.insert()
        let question = viewModel.level.leitner?.allQuestions.first(where: { $0.question == "New Question" })
        XCTAssertEqual(question?.completed, true)
        XCTAssertTrue(question?.answer == "Answer")
        XCTAssertTrue(question?.question == "New Question")
        XCTAssertTrue(question?.detailDescription == "Descrition")
        XCTAssertEqual(question?.favorite, true)
        XCTAssertEqual(question?.level?.level, 13)

        viewModel.isCompleted = false
        viewModel.questionString = "TestNewQuestionCompletedFalse"
        viewModel.insert()
        let notCompletedQuestion = viewModel.level.leitner?.allQuestions.first(where: { $0.question == "TestNewQuestionCompletedFalse" })
        XCTAssertEqual(notCompletedQuestion?.completed, false)
        XCTAssertEqual(notCompletedQuestion?.level?.level, 1)
    }

    func test_save() {
        viewModel.clear()
        let beforeCount = viewModel.level.leitner?.allQuestions.count ?? 0
        viewModel.answer = "New Question"
        viewModel.save()
        let afterCount = viewModel.level.leitner?.allQuestions.count ?? 0
        XCTAssertLessThan(beforeCount, afterCount)
    }

    func test_save_update() {
        let question = viewModel.level.allQuestions.first!
        viewModel.question = question
        viewModel.answer = "Updated answer"
        viewModel.isInEditMode = true
        viewModel.save()
        XCTAssertEqual(question.answer, "Updated answer")
    }

    func test_clear() {
        let question = viewModel.level.allQuestions.first!
        viewModel.questionString = "New Question"
        viewModel.answer = "Answer"
        viewModel.question = question
        viewModel.descriptionDetail = "Descrition"
        viewModel.clear()

        XCTAssertEqual(viewModel.isManual, true)
        XCTAssertEqual(viewModel.isFavorite, false)
        XCTAssertEqual(viewModel.isCompleted, false)
        XCTAssertTrue(viewModel.answer == "")
        XCTAssertTrue(viewModel.questionString == "")
        XCTAssertTrue(viewModel.descriptionDetail == "")
    }
}
