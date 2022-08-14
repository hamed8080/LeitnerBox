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
        let tagToAdd = vm.level.leitner!.tagsArray.first
        vm.addedTags = [tagToAdd!]
        vm.editQuestion = question
        vm.saveEdit()
        XCTAssertEqual(question.completed, vm.isCompleted)
        XCTAssertEqual(question.answer, vm.answer)
        XCTAssertEqual(question.question, vm.question)
        XCTAssertEqual(question.detailDescription, vm.descriptionDetail)
        XCTAssertEqual(question.favorite, vm.isFavorite)
        let tagAdded = question.tagsArray?.contains(where: {$0.objectID == tagToAdd?.objectID})
        XCTAssertNotNil(tagAdded)
        
        
        let questionWithFav = vm.level.allQuestions.first!
        vm.editQuestion = questionWithFav
        vm.isFavorite = true
        vm.saveEdit()
        XCTAssertEqual(questionWithFav.favorite, true)
    }
    
    func test_insert(){
        let tagToAdd = vm.level.leitner!.tagsArray.first
        vm.addedTags = [tagToAdd!]
        vm.question = "New Question"
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
        let tagAdded = question?.tagsArray?.contains(where: {$0.objectID == tagToAdd?.objectID})
        XCTAssertNotNil(tagAdded)
        
        
        vm.isCompleted = false
        vm.question = "TestNewQuestionCompletedFalse"
        vm.insert()
        let notCompletedQuestion = vm.level.leitner?.allQuestions.first(where: {$0.question == "TestNewQuestionCompletedFalse"})
        XCTAssertEqual(notCompletedQuestion?.completed, false)
        XCTAssertEqual(notCompletedQuestion?.level?.level, 1)
    }
    
    func test_save(){
        let question = vm.level.allQuestions.first!
        vm.editQuestion = question
        vm.answer = "Updated answer"
        vm.save()
        XCTAssertEqual(question.answer, "Updated answer")
        let beforeCount = vm.level.leitner?.allQuestions.count ?? 0
        vm.editQuestion = nil
        vm.answer = "New Question"
        vm.save()
        let afterCount = vm.level.leitner?.allQuestions.count ?? 0
        XCTAssertLessThan(beforeCount, afterCount)
    }
    
    func test_clear(){
        let question = vm.level.allQuestions.first!
        let tagToAdd = vm.level.leitner!.tagsArray.first
        vm.addedTags = [tagToAdd!]
        vm.question = "New Question"
        vm.answer = "Answer"
        vm.editQuestion = question
        vm.descriptionDetail  = "Descrition"
        vm.clear()
        
        XCTAssertNil(vm.editQuestion)
        XCTAssertEqual(vm.isManual, true)
        XCTAssertEqual(vm.isFavorite, false)
        XCTAssertEqual(vm.isCompleted, false)
        XCTAssertTrue(vm.answer == "")
        XCTAssertTrue(vm.question == "")
        XCTAssertTrue(vm.descriptionDetail == "")
        XCTAssertTrue(vm.addedTags.count == 0)
    }
    
    func test_add_tag_to_question(){
        let newTag = Tag(context: vm.viewContext)
        newTag.name = "Test"
        vm.tags.append(newTag)
        if let tag = vm.tags.filter({$0.question?.count ?? 0 > 0}).first, let firstQuestion = tag.questions.first{
            let oldQuestionTagCounts = firstQuestion.tag?.count ?? 0
            vm.editQuestion = firstQuestion
            vm.addTagToQuestion(newTag)
            vm.save()
            let updatedQuestion = vm.level.leitner?.findQuestion(objectID: firstQuestion.objectID)
            XCTAssertEqual(updatedQuestion?.tagsArray?.count ?? 0, oldQuestionTagCounts + 1, "Tags not added")
        }
    }
    
    func test_remove_tag_for_question(){
        let question = vm.level.leitner!.allQuestions.first!
        let tag = question.tagsArray!.first!
        let oldQuestionTagCounts = question.tagsArray?.count ?? 0
        vm.editQuestion = question
        vm.removeTagForQuestio(tag)
        vm.save()
        let updatedQuestion = vm.level.leitner?.findQuestion(objectID: question.objectID)
        XCTAssertEqual(updatedQuestion?.tagsArray?.count ?? 0, oldQuestionTagCounts - 1, "Tags not removed")
    }
}

