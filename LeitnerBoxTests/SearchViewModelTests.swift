//
// SearchViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/19/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class SearchViewModelTests: XCTestCase {
    var vm: SearchViewModel!

    override func setUp() {
        let leitner = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext).leitners.first!
        vm = SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner)
    }

    func test_delete_items_with_offset() {
        let beforeCount = vm.leitner.allQuestions.count
        vm.deleteItems(offsets: IndexSet(0 ..< 2))
        XCTAssertTrue(beforeCount > vm.leitner.allQuestions.count)
    }

    func test_delete_item() {
        let beforeCount = vm.leitner.allQuestions.count
        vm.delete(vm.leitner.allQuestions.first!)
        XCTAssertTrue(beforeCount > vm.leitner.allQuestions.count)
    }

    func test_sort() {
        vm.sort(.LEVEL)
        XCTAssertTrue(vm.sorted.first?.level?.level ?? 0 < vm.sorted.last?.level?.level ?? 0)

        vm.sort(.COMPLETED)
        XCTAssertTrue(((vm.sorted.first?.completed ?? false) ? 1 : 0) > ((vm.sorted.last?.completed ?? false) ? 1 : 0))

        vm.sort(.ALPHABET)
        XCTAssertTrue(vm.sorted.first?.question ?? "" < vm.sorted.last?.question ?? "")

        vm.sort(.FAVORITE)
        XCTAssertTrue(((vm.sorted.first?.favorite ?? false) ? 1 : 0) > ((vm.sorted.last?.favorite ?? false) ? 1 : 0))

        vm.sort(.PASSED_TIME)
        XCTAssertTrue(vm.sorted.first?.passTime?.timeIntervalSince1970 ?? -1 > vm.sorted.last?.passTime?.timeIntervalSince1970 ?? -1)

        vm.sort(.DATE)
        XCTAssertTrue(vm.sorted.first?.createTime?.timeIntervalSince1970 ?? -1 > vm.sorted.last?.createTime?.timeIntervalSince1970 ?? -1)

        vm.sort(.NO_TAGS)
        XCTAssertTrue(vm.sorted.first?.tagsArray?.count ?? -1 < vm.sorted.last?.tagsArray?.count ?? -1)

        vm.sort(.TAGS)
        XCTAssertTrue(vm.sorted.first?.tagsArray?.count ?? -1 > vm.sorted.last?.tagsArray?.count ?? -1)
    }

    func test_toggle_completed() {
        let question = vm.leitner.allQuestions.first!
        let beforeState = question.completed
        vm.toggleCompleted(question)
        let updated = vm.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertNotEqual(updated.completed, beforeState, "toggle completed not worked!")
    }

    func test_toggle_favorite() {
        let question = vm.leitner.allQuestions.first!
        let beforeState = question.favorite
        vm.toggleFavorite(question)
        let updated = vm.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertNotEqual(updated.favorite, beforeState, "toggle favorite not worked!")
    }

    func test_reset_to_first_level() {
        let question = vm.leitner.allQuestions.first(where: { $0.level?.level ?? 0 > 1 })!
        vm.resetToFirstLevel(question)
        let updated = vm.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertEqual(updated.level?.level ?? 0, 1, "Level didn't reset to first level")
        XCTAssertEqual(updated.completed, false, "Level completed didn't reset to false")
        XCTAssertNil(updated.passTime, "Passed time is not nil")
    }

    func test_set_a_question_completed() {
        let question = vm.leitner.allQuestions.first(where: { $0.level?.level ?? 0 > 1 })!
        vm.complete(question)
        let updated = vm.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertEqual(updated.level?.level ?? 0, 13, "Level didn't reset to completed level")
        XCTAssertEqual(updated.completed, true, "Level completed didn't reset to true")
        XCTAssertNotNil(updated.passTime, "Passed time is nil")
    }

    func test_filter() {
        vm.searchText = ""
        XCTAssertEqual(vm.filtered.count, vm.leitner.allQuestions.count, "filter count is not equal to all questions!")

        vm.searchText = "#"
        XCTAssertEqual(vm.filtered.count, vm.leitner.allQuestions.count, "filter count is not equal to all questions!")

        vm.searchText = "#Tag"
        XCTAssertGreaterThan(vm.filtered.count, 0, "couldn't find any tag!")

        vm.searchText = "Quesiton"
        XCTAssertGreaterThan(vm.filtered.count, 0, "couldn't find any quetion!")
    }

    func test_has_next() {
        vm.lastPlayedQuestion = vm.sorted.first!
        XCTAssertTrue(vm.hasNext(), "The Array should have next Item!")

        vm.lastPlayedQuestion = vm.sorted.last!
        XCTAssertFalse(vm.hasNext(), "The Array should not have next Item!")
    }

    func test_toggle_is_speaking() {
        let beforeState = vm.reviewStatus
        vm.togglePlayPauseReview()
        XCTAssertNotEqual(vm.reviewStatus, beforeState, "is playing is not working properly!")
    }

    func test_is_speaking() {
        vm.togglePlayPauseReview()
        XCTAssertEqual(vm.reviewStatus == .isPlaying, true, "is Speaking not working properly!")
    }

    func test_play_review() {
        vm.togglePlayPauseReview()
        vm.selectedVoiceIdentifire = "com.apple.ttsbundle.Samantha-compact"
        XCTAssertEqual(vm.reviewStatus == .isPlaying, true, "is Speaking not working properly!")
    }

    func test_move_question() {
        let leitner = LeitnerViewModel(viewContext: vm.viewContext).leitners.last!
        let question = vm.sorted.first(where: { $0.completed == true })!
        vm.moveQuestionTo(question, leitner: leitner)

        let movedQuestion = leitner.allQuestions.first(where: { $0.objectID == question.objectID })
        XCTAssertEqual(movedQuestion?.completed, false)
        XCTAssertNil(movedQuestion?.passTime)
        XCTAssertEqual(movedQuestion?.level?.level, 1)
        XCTAssertFalse(vm.sorted.contains(where: { $0.objectID == movedQuestion?.objectID }))
    }

    func test_procounce_once() {
        vm.pronounceOnce(vm.leitner.allQuestions.first!)
        XCTAssertFalse(vm.reviewStatus == .isPlaying)
    }

    func test_play_next() {
        vm.playNext()
        XCTAssertEqual(vm.reviewStatus, .unInitialized)

        vm.lastPlayedQuestion = vm.leitner.allQuestions.first!
        vm.playNext()
        XCTAssertGreaterThanOrEqual(vm.leitner.allQuestions.count, 1)
        XCTAssertNotNil(vm.lastPlayedQuestion)
    }

    func test_play_immediately() {
        vm.lastPlayedQuestion = vm.leitner.allQuestions.first!
        let lastIndex = vm.leitner.allQuestions.firstIndex(where: { $0 == vm.lastPlayedQuestion })
        vm.playNextImmediately()
        let newIndex = vm.leitner.allQuestions.firstIndex(where: { $0 == vm.lastPlayedQuestion })
        XCTAssertNotEqual(newIndex, lastIndex)
        XCTAssertNotNil(vm.synthesizer.delegate)
    }

    func test_pause_speaking() {
        vm.togglePlayPauseReview()
        XCTAssertEqual(vm.reviewStatus, .isPlaying)

        vm.pauseReview()
        XCTAssertEqual(vm.reviewStatus, .isPaused)
        XCTAssertEqual(vm.speechDelegate.task?.isCancelled ?? false, false)
    }

    func test_stop_speaking() {
        vm.togglePlayPauseReview()
        XCTAssertEqual(vm.reviewStatus, .isPlaying)

        vm.stopReview()
        XCTAssertEqual(vm.reviewStatus, .unInitialized)
        XCTAssertNil(vm.lastPlayedQuestion)
        XCTAssertEqual(vm.speechDelegate.task?.isCancelled ?? false, false)
    }

    func test_finished() {
        vm.finished()
        XCTAssertEqual(vm.reviewStatus, .unInitialized)
        XCTAssertNil(vm.lastPlayedQuestion)
    }

    func test_review_count() {
        vm.lastPlayedQuestion = vm.sorted.first!
        XCTAssertEqual(vm.reviewdCount, 1)

        vm.lastPlayedQuestion = nil
        XCTAssertEqual(vm.reviewdCount, 0)
    }
}
