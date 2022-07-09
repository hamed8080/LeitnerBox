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
        let question = vm.insert()
        XCTAssertEqual(question.completed, true)
        XCTAssertTrue(question.answer == "Answer")
        XCTAssertTrue(question.question == "New Question")
        XCTAssertTrue(question.detailDescription == "Descrition")
        XCTAssertEqual(question.favorite, true)
        XCTAssertEqual(question.level?.level, 13)
        let tagAdded = question.tagsArray?.contains(where: {$0.objectID == tagToAdd?.objectID})
        XCTAssertNotNil(tagAdded)
        
        
        vm.isCompleted = false
        let notCompletedQuestion = vm.insert()
        XCTAssertEqual(notCompletedQuestion.completed, false)
        XCTAssertEqual(notCompletedQuestion.level?.level, 1)
    }
    
    func test_save(){
        let question = vm.level.allQuestions.first!
        vm.editQuestion = question
        vm.answer = "Updated answer"
        let updatedState = vm.save()
        XCTAssertTrue(question.answer == "Updated answer")
        switch updatedState {
        case .EDITED(_):
            XCTAssertTrue(question.answer == "Updated answer")
        case .DELTED(_):
            XCTFail()
        case .INSERTED(_):
            XCTFail()
        }
        
        vm.editQuestion = nil
        vm.answer = "New Question"
        let questionState = vm.save()
        switch questionState {
        case .EDITED(_):
            XCTFail()
        case .DELTED(_):
            XCTFail()
        case .INSERTED(let question):
            XCTAssertTrue(question.answer == "New Question")
        }
        
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
            _ = vm.save()
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
        _ = vm.save()
        let updatedQuestion = vm.level.leitner?.findQuestion(objectID: question.objectID)
        XCTAssertEqual(updatedQuestion?.tagsArray?.count ?? 0, oldQuestionTagCounts - 1, "Tags not removed")
        
    }
}

