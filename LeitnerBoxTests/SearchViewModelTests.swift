//
//  SearchViewModelTests.swift
//  ReviewViewModelTests
//
//  Created by hamed on 7/2/22.
//

import XCTest
import SwiftUI
@testable import LeitnerBox

final class SearchViewModelTests: XCTestCase {
    
    var vm:SearchViewModel!
    
    override func setUp() {
        let leitner = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext).leitners.first!
        vm = SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner)
    }
    
    func test_delete_items_with_offset(){
        let beforeCount = vm.questions.count
        vm.deleteItems(offsets: IndexSet(0..<2))
        XCTAssertTrue(beforeCount > vm.questions.count)
    }
    
    func test_delete_item(){
        let beforeCount = vm.questions.count
        vm.delete(vm.questions.first!)
        XCTAssertTrue(beforeCount > vm.questions.count)
    }
    
    func test_sort(){
        vm.sort(.LEVEL)
        XCTAssertTrue(vm.questions.first?.level?.level ?? 0 < vm.questions.last?.level?.level ?? 0)
        
        vm.sort(.COMPLETED)
        XCTAssertTrue( ((vm.questions.first?.completed ?? false) ? 1 : 0) > ( (vm.questions.last?.completed ?? false) ? 1 : 0 ))
        
        vm.sort(.ALPHABET)
        XCTAssertTrue(vm.questions.first?.question ?? "" < vm.questions.last?.question ?? "")
        
        vm.sort(.FAVORITE)
        XCTAssertTrue(((vm.questions.first?.favorite ?? false) ? 1 : 0) > ((vm.questions.last?.favorite ?? false) ? 1 : 0))
        
        vm.sort(.PASSED_TIME)
        XCTAssertTrue(vm.questions.first?.passTime?.timeIntervalSince1970 ?? -1 > vm.questions.last?.passTime?.timeIntervalSince1970 ?? -1)
        
        vm.sort(.DATE)
        XCTAssertTrue(vm.questions.first?.createTime?.timeIntervalSince1970 ?? -1 > vm.questions.last?.createTime?.timeIntervalSince1970 ?? -1)
        
        vm.sort(.NO_TAGS)
        XCTAssertTrue(vm.questions.first?.tagsArray?.count ?? -1 < vm.questions.last?.tagsArray?.count ?? -1)
        
        vm.sort(.TAGS)
        XCTAssertTrue(vm.questions.first?.tagsArray?.count ?? -1 > vm.questions.last?.tagsArray?.count ?? -1)
    }
    
    func test_toggle_completed(){
        let question = vm.questions.first!
        let beforeState = question.completed
        vm.toggleCompleted(question)
        let updated = vm.questions.first(where: {$0.objectID == question.objectID})!
        XCTAssertNotEqual(updated.completed, beforeState, "toggle completed not worked!")
    }
    
    func test_toggle_favorite(){
        let question = vm.questions.first!
        let beforeState = question.favorite
        vm.toggleFavorite(question)
        let updated = vm.questions.first(where: {$0.objectID == question.objectID})!
        XCTAssertNotEqual(updated.favorite, beforeState, "toggle favorite not worked!")
    }
    
    func test_reset_to_first_level(){
        let question = vm.questions.first(where: {$0.level?.level ?? 0 > 1})!
        vm.resetToFirstLevel(question)
        let updated = vm.questions.first(where: {$0.objectID == question.objectID})!
        XCTAssertEqual(updated.level?.level ?? 0, 1, "Level didn't reset to first level")
        XCTAssertEqual(updated.completed, false, "Level completed didn't reset to false")
        XCTAssertNil(updated.passTime, "Passed time is not nil")
    }
    
    func test_set_a_question_completed(){
        let question = vm.questions.first(where: {$0.level?.level ?? 0 > 1})!
        vm.complete(question)
        let updated = vm.questions.first(where: {$0.objectID == question.objectID})!
        XCTAssertEqual(updated.level?.level ?? 0, 13, "Level didn't reset to completed level")
        XCTAssertEqual(updated.completed, true, "Level completed didn't reset to true")
        XCTAssertNotNil(updated.passTime, "Passed time is nil")
    }
    
    func test_filter(){
        vm.searchText = ""
        XCTAssertEqual(vm.filtered.count, vm.questions.count, "filter count is not equal to all questions!")
        
        vm.searchText = "#"
        XCTAssertEqual(vm.filtered.count, vm.questions.count, "filter count is not equal to all questions!")

        vm.searchText = "#Tag"
        XCTAssertGreaterThan(vm.filtered.count, 0, "couldn't find any tag!")
        
        vm.searchText = "Quesiton"
        XCTAssertGreaterThan(vm.filtered.count, 0, "couldn't find any quetion!")
    }
    
    func test_remove_tag_for_question(){
        let question = vm.questions.first!
        let tagCountBefore = question.tag?.count ?? 0
        let tag = question.tagsArray!.first!
        vm.removeTagForQuestion(question, tag)
        let updated = vm.questions.first(where: {$0.objectID == question.objectID})
        XCTAssertLessThan(updated?.tagsArray?.count ?? 0, tagCountBefore, "Tag not removed properly!")
    }
    
    func test_has_next(){
        vm.lastPlayedQuestion = vm.questions.first!
        XCTAssertTrue(vm.hasNext(), "The Array should have next Item!")
        
        vm.lastPlayedQuestion = vm.questions.last!
        XCTAssertFalse(vm.hasNext(), "The Array should not have next Item!")
        
        vm.questions.removeAll()
        XCTAssertFalse(vm.hasNext(), "The Array is clear and should not have next!")
    }
    
    func test_toggle_is_speaking(){
        let beforeState = vm.isSpeaking
        vm.togglePlayPauseReview()
        XCTAssertNotEqual(vm.isSpeaking, beforeState, "is speaking is not working properly!")
    }
    
    func test_is_speaking(){
        vm.isSpeaking = false
        vm.togglePlayPauseReview()
        XCTAssertEqual(vm.isSpeaking, true, "is Speaking not working properly!")
    }
    
    func test_play_review(){
        vm.togglePlayPauseReview()
        vm.selectedVoiceIdentifire = "com.apple.ttsbundle.Samantha-compact"
        XCTAssertEqual(vm.isSpeaking, true, "is Speaking not working properly!")
    }
    
    func test_delete_question(){
        let question = vm.questions.last!
        XCTAssertTrue(vm.questions.contains(where: {$0.objectID == question.objectID}))
        vm.qustionStateChanged(.DELTED(question))
        XCTAssertFalse(vm.questions.contains(where: {$0.objectID == question.objectID}), "the object not deleted!")
    }
    
    func test_edited_question(){
        let question = vm.questions.last!
        question.question = "TestUpdated"
        vm.qustionStateChanged(.EDITED(question))
        let updatedQuestion = vm.questions.first(where: {$0.objectID == question.objectID})!
        XCTAssertEqual(updatedQuestion.question, "TestUpdated" , "the object not edited!")
    }
    
    func test_insert_question(){
        let beforeCount = vm.questions.count
        let question = Question(context: PersistenceController.preview.container.viewContext)
        question.question = "TestInserted"
        vm.qustionStateChanged(.INSERTED(question))
        let insertedQuestion = vm.questions.first(where: {$0.objectID == question.objectID})!
        XCTAssertEqual(insertedQuestion.question, "TestInserted" , "the object not inserted!")
        XCTAssertTrue(beforeCount < vm.questions.count, "Item seems to not added to array")
    }
    
    func test_move_question(){
        let leitner = LeitnerViewModel(viewContext: vm.viewContext).leitners.last!
        vm.selectedQuestion = vm.questions.first!
        vm.moveQuestionTo(leitner)
        
        XCTAssertEqual(vm.selectedQuestion?.completed, false)
        XCTAssertNil(vm.selectedQuestion?.passTime)
        XCTAssertEqual(vm.selectedQuestion?.level?.level, 1)
        XCTAssertFalse(vm.questions.contains(where: {$0.objectID == vm.selectedQuestion?.objectID}))
    }
    
    func test_procounce_once(){
        vm.pronounceOnce(vm.questions.first!)
        XCTAssertFalse(vm.isSpeaking)
    }
    
    func test_play_next(){
        vm.playNext()
        XCTAssertEqual(vm.isSpeaking, false)
        
        vm.lastPlayedQuestion = vm.questions.first!
        vm.playNext()
        XCTAssertGreaterThanOrEqual(vm.questions.count, 1)
        XCTAssertNotNil(vm.lastPlayedQuestion)
    }
    
    func test_play_immediately(){
        vm.lastPlayedQuestion = vm.questions.first!
        let lastIndex = vm.questions.firstIndex(where: {$0 == vm.lastPlayedQuestion})
        vm.playNextImmediately()
        let newIndex = vm.questions.firstIndex(where: {$0 == vm.lastPlayedQuestion})
        XCTAssertNotEqual(newIndex, lastIndex)
        XCTAssertNotNil(vm.synthesizer.delegate)
    }
    
    func test_pause_speaking(){
        vm.togglePlayPauseReview()
        XCTAssertTrue(vm.isSpeaking)
        
        vm.pauseReview()
        XCTAssertFalse(vm.isSpeaking)
        XCTAssertEqual(vm.speechDelegate.timer?.isValid ?? false, false)
    }
    
    func test_stop_speaking(){
        vm.togglePlayPauseReview()
        XCTAssertTrue(vm.isSpeaking)
        
        vm.stopReview()
        XCTAssertFalse(vm.isSpeaking)
        XCTAssertNil(vm.lastPlayedQuestion)
        XCTAssertEqual(vm.speechDelegate.timer?.isValid ?? false, false)
    }
    
    func test_finished(){
        vm.finished()
        XCTAssertFalse(vm.isSpeaking)
        XCTAssertNil(vm.lastPlayedQuestion)
    }
    
    func test_review_count(){
        vm.lastPlayedQuestion = vm.questions.first!
        XCTAssertEqual(vm.reviewdCount, 1)
        
        vm.lastPlayedQuestion = nil
        XCTAssertEqual(vm.reviewdCount, 0)
    }
}

