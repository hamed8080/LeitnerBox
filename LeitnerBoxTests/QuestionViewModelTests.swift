//
//  QuestionViewModelTests.swift
//  QuestionViewModelTests
//
//  Created by hamed on 7/2/22.
//

import XCTest
import SwiftUI
@testable import LeitnerBox

final class QuestionViewModelTests: XCTestCase {
    
    var vm:QuestionViewModel!
    
    override func setUp() {
        PersistenceController.generateAndFillLeitner()
        let leitner = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext).leitners.first!
        let level = LevelsViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner).levels.first(where: {$0.level == 1})!
        vm = QuestionViewModel(viewContext: PersistenceController.preview.container.viewContext, level: level)
    }

    func test_save_edit(){
        let question = vm.level.allQuestions.first!
        vm.editQuestion = question
        vm.saveEdit()
        XCTAssertEqual(question.completed, vm.isCompleted)
        XCTAssertEqual(question.answer, vm.answer)
        XCTAssertEqual(question.question, vm.questionString)
        XCTAssertEqual(question.detailDescription, vm.descriptionDetail)
        XCTAssertEqual(question.favorite, vm.isFavorite)
        
        
        let questionWithFav = vm.level.allQuestions.first!
        vm.editQuestion = questionWithFav
        vm.isFavorite = true
        vm.saveEdit()
        XCTAssertEqual(questionWithFav.favorite, true)
    }
    
    func test_insert(){
        vm.questionString = "New Question"
        vm.answer = "Answer"
        vm.descriptionDetail  = "Descrition"
        vm.isCompleted = true
        vm.isFavorite = true
        vm.insert()
        let question = vm.level.leitner?.allQuestions.first(where: {$0.question == "New Question"})
        XCTAssertEqual(question?.completed, true)
        XCTAssertTrue(question?.answer == "Answer")
        XCTAssertTrue(question?.question == "New Question")
        XCTAssertTrue(question?.detailDescription == "Descrition")
        XCTAssertEqual(question?.favorite, true)
        XCTAssertEqual(question?.level?.level, 13)
        
        
        vm.isCompleted = false
        vm.questionString = "TestNewQuestionCompletedFalse"
        vm.insert()
        let notCompletedQuestion = vm.level.leitner?.allQuestions.first(where: {$0.question == "TestNewQuestionCompletedFalse"})
        XCTAssertEqual(notCompletedQuestion?.completed, false)
        XCTAssertEqual(notCompletedQuestion?.level?.level, 1)
    }
    
    func test_save(){
        let question = vm.level.allQuestions.first!
        vm.editQuestion = question
        vm.answer = "Updated answer"
        vm.isInEditMode = true
        vm.save()
        XCTAssertEqual(question.answer, "Updated answer")
        vm.clear()
        let beforeCount = vm.level.leitner?.allQuestions.count ?? 0
        vm.answer = "New Question"
        vm.save()
        let afterCount = vm.level.leitner?.allQuestions.count ?? 0
        XCTAssertLessThan(beforeCount, afterCount)
    }
    
    func test_clear(){
        let question = vm.level.allQuestions.first!
        vm.questionString = "New Question"
        vm.answer = "Answer"
        vm.editQuestion = question
        vm.descriptionDetail  = "Descrition"
        vm.clear()

        XCTAssertEqual(vm.isManual, true)
        XCTAssertEqual(vm.isFavorite, false)
        XCTAssertEqual(vm.isCompleted, false)
        XCTAssertTrue(vm.answer == "")
        XCTAssertTrue(vm.questionString == "")
        XCTAssertTrue(vm.descriptionDetail == "")
        XCTAssertNil(vm.editQuestion)
    }
}

