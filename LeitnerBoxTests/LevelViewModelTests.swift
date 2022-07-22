//
//  LevelViewModelTests.swift
//  ReviewViewModelTests
//
//  Created by hamed on 7/2/22.
//

import XCTest
import SwiftUI
@testable import LeitnerBox

final class LevelViewModelTests: XCTestCase {
    
    var vm:LevelsViewModel!
    
    override func setUp() {
        let leitner = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext).leitners.first!
        vm = LevelsViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner)
    }
    
    func test_delete_question(){
        let question = vm.allQuestions.last!
        XCTAssertTrue(vm.allQuestions.contains(where: {$0.objectID == question.objectID}))
        vm.questionStateChanged(state: .DELTED(question))
        XCTAssertFalse(vm.allQuestions.contains(where: {$0.objectID == question.objectID}), "the object not deleted!")
    }
    
    func test_edited_question(){
        let question = vm.allQuestions.last!
        question.question = "TestUpdated"
        vm.questionStateChanged(state: .EDITED(question))
        let updatedQuestion = vm.allQuestions.first(where: {$0.objectID == question.objectID})!
        XCTAssertEqual(updatedQuestion.question, "TestUpdated" , "the object not edited!")
    }
    
    func test_insert_question(){
        let beforeCount = vm.allQuestions.count
        let question = Question(context: PersistenceController.preview.container.viewContext)
        question.question = "TestInserted"
        vm.questionStateChanged(state: .INSERTED(question))
        let insertedQuestion = vm.allQuestions.first(where: {$0.objectID == question.objectID})!
        XCTAssertEqual(insertedQuestion.question, "TestInserted" , "the object not inserted!")
        XCTAssertTrue(beforeCount < vm.allQuestions.count, "Item seems to not added to array")
    }
    
    func test_filter(){
        vm.searchWord = ""
        XCTAssertTrue(vm.filtered.count == 0, "filter count is not equal all question!")
        
        vm.searchWord = "#"
        XCTAssertTrue(vm.filtered.count == 0, "empty tag is not equal all question!")

        
        vm.searchWord = "#Tag"
        XCTAssertTrue(vm.filtered.count > 0, "couldn't find any tag!")
        
        vm.searchWord = "Quesiton"
        XCTAssertTrue(vm.filtered.count > 0, "couldn't find any quetion!")
    }
    
    func test_edit_days_to_recommend(){
        vm.selectedLevel = vm.levels.first!
        vm.daysToRecommend = 365
        vm.saveDaysToRecommned()
        XCTAssertEqual(vm.levels.first(where: {$0.objectID == vm.selectedLevel?.objectID})?.daysToRecommend, 365)
    }

    func test_performance(){
        measure {
            vm.load()
        }
    }
}

