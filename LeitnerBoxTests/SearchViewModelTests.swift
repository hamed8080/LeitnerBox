//
// SearchViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

@testable import LeitnerBox
import SwiftUI
import XCTest
import AVFoundation

final class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!

    override func setUp() {
        try? PersistenceController.shared.generateAndFillLeitner()
        let leitner = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext, voices: []).leitners.first!
        let mockSpeach = MockAVSpeechSynthesisVoice()
        let mockSynthesizer = MockAVSpeechSynthesizer()
        viewModel = SearchViewModel(viewContext: PersistenceController.shared.viewContext,
                                    leitner: leitner,
                                    voiceSpeech: mockSpeach,
                                    synthesizer: mockSynthesizer
        )
    }

    func test_delete_items_with_offset() {
        let beforeCount = viewModel.leitner.allQuestions.count
        viewModel.deleteItems(offsets: IndexSet(0 ..< 2))
        XCTAssertTrue(beforeCount > viewModel.leitner.allQuestions.count)
    }

    func test_delete_item() {
        let beforeCount = viewModel.leitner.allQuestions.count
        viewModel.delete(viewModel.leitner.allQuestions.first!)
        XCTAssertTrue(beforeCount > viewModel.leitner.allQuestions.count)
    }

    func test_sort() {
        viewModel.sort(.level)
        XCTAssertTrue(viewModel.sorted.first?.level?.level ?? 0 < viewModel.sorted.last?.level?.level ?? 0)

        viewModel.sort(.completed)
        XCTAssertTrue(((viewModel.sorted.first?.completed ?? false) ? 1 : 0) > ((viewModel.sorted.last?.completed ?? false) ? 1 : 0))

        viewModel.sort(.alphabet)
        XCTAssertTrue(viewModel.sorted.first?.question ?? "" < viewModel.sorted.last?.question ?? "")

        viewModel.sort(.favorite)
        XCTAssertTrue(((viewModel.sorted.first?.favorite ?? false) ? 1 : 0) > ((viewModel.sorted.last?.favorite ?? false) ? 1 : 0))

        viewModel.sort(.passedTime)
        XCTAssertTrue(viewModel.sorted.first?.passTime?.timeIntervalSince1970 ?? -1 > viewModel.sorted.last?.passTime?.timeIntervalSince1970 ?? -1)

        viewModel.sort(.date)
        XCTAssertTrue(viewModel.sorted.first?.createTime?.timeIntervalSince1970 ?? -1 > viewModel.sorted.last?.createTime?.timeIntervalSince1970 ?? -1)

        viewModel.sort(.noTags)
        XCTAssertTrue(viewModel.sorted.first?.tagsArray?.count ?? -1 < viewModel.sorted.last?.tagsArray?.count ?? -1)

        viewModel.sort(.tags)
        XCTAssertTrue(viewModel.sorted.first?.tagsArray?.count ?? -1 > viewModel.sorted.last?.tagsArray?.count ?? -1)
    }

    func test_toggle_completed() {
        let question = viewModel.leitner.allQuestions.first!
        let beforeState = question.completed
        viewModel.toggleCompleted(question)
        let updated = viewModel.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertNotEqual(updated.completed, beforeState, "toggle completed not worked!")
    }

    func test_toggle_favorite() {
        let question = viewModel.leitner.allQuestions.first!
        let beforeState = question.favorite
        viewModel.toggleFavorite(question)
        let updated = viewModel.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertNotEqual(updated.favorite, beforeState, "toggle favorite not worked!")
    }

    func test_reset_to_first_level() {
        let question = viewModel.leitner.allQuestions.first(where: { $0.level?.level ?? 0 > 1 })!
        viewModel.resetToFirstLevel(question)
        let updated = viewModel.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertEqual(updated.level?.level ?? 0, 1, "Level didn't reset to first level")
        XCTAssertEqual(updated.completed, false, "Level completed didn't reset to false")
        XCTAssertNil(updated.passTime, "Passed time is not nil")
    }

    func test_set_a_question_completed() {
        let question = viewModel.leitner.allQuestions.first(where: { $0.level?.level ?? 0 > 1 })!
        viewModel.complete(question)
        let updated = viewModel.leitner.allQuestions.first(where: { $0.objectID == question.objectID })!
        XCTAssertEqual(updated.level?.level ?? 0, 13, "Level didn't reset to completed level")
        XCTAssertEqual(updated.completed, true, "Level completed didn't reset to true")
        XCTAssertNotNil(updated.passTime, "Passed time is nil")
    }

    func test_filter() {
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filtered.count, viewModel.leitner.allQuestions.count, "filter count is not equal to all questions!")

        viewModel.searchText = "#"
        XCTAssertEqual(viewModel.filtered.count, viewModel.leitner.allQuestions.count, "filter count is not equal to all questions!")

        viewModel.searchText = "#Tag"
        XCTAssertGreaterThan(viewModel.filtered.count, 0, "couldn't find any tag!")

        viewModel.searchText = "Quesiton"
        XCTAssertGreaterThan(viewModel.filtered.count, 0, "couldn't find any quetion!")
    }

    func test_has_next() {
        viewModel.lastPlayedQuestion = viewModel.sorted.first!
        XCTAssertTrue(viewModel.hasNext(), "The Array should have next Item!")

        viewModel.lastPlayedQuestion = viewModel.sorted.last!
        XCTAssertFalse(viewModel.hasNext(), "The Array should not have next Item!")
    }

    func test_toggle_is_speaking() {
        let beforeState = viewModel.reviewStatus
        viewModel.togglePlayPauseReview()
        XCTAssertNotEqual(viewModel.reviewStatus, beforeState, "is playing is not working properly!")
    }

    func test_is_speaking() {
        viewModel.togglePlayPauseReview()
        XCTAssertEqual(viewModel.reviewStatus == .isPlaying, true, "is Speaking not working properly!")
    }

    func test_play_review() {
        viewModel.togglePlayPauseReview()
        viewModel.selectedVoiceIdentifire = "com.apple.ttsbundle.Samantha-compact"
        XCTAssertEqual(viewModel.reviewStatus == .isPlaying, true, "is Speaking not working properly!")
    }

    func test_move_question() {
        let leitner = LeitnerViewModel(viewContext: viewModel.viewContext).leitners.last!
        let question = viewModel.sorted.first(where: { $0.completed == true })!
        viewModel.moveQuestionTo(question, leitner: leitner)

        let movedQuestion = leitner.allQuestions.first(where: { $0.objectID == question.objectID })
        XCTAssertEqual(movedQuestion?.completed, false)
        XCTAssertNil(movedQuestion?.passTime)
        XCTAssertEqual(movedQuestion?.level?.level, 1)
        XCTAssertFalse(viewModel.sorted.contains(where: { $0.objectID == movedQuestion?.objectID }))
    }

    func test_procounce_once() {
        viewModel.pronounceOnce(viewModel.leitner.allQuestions.first!)
        XCTAssertFalse(viewModel.reviewStatus == .isPlaying)
    }

    func test_play_next() {
        viewModel.playNext()
        XCTAssertEqual(viewModel.reviewStatus, .unInitialized)

        viewModel.lastPlayedQuestion = viewModel.leitner.allQuestions.first!
        viewModel.playNext()
        XCTAssertGreaterThanOrEqual(viewModel.leitner.allQuestions.count, 1)
        XCTAssertNotNil(viewModel.lastPlayedQuestion)
    }

    func test_play_immediately() {
        viewModel.lastPlayedQuestion = viewModel.leitner.allQuestions.first!
        let lastIndex = viewModel.leitner.allQuestions.firstIndex(where: { $0 == viewModel.lastPlayedQuestion })
        viewModel.playNextImmediately()
        let newIndex = viewModel.leitner.allQuestions.firstIndex(where: { $0 == viewModel.lastPlayedQuestion })
        XCTAssertNotEqual(newIndex, lastIndex)
        XCTAssertNotNil(viewModel.synthesizer.delegate)
    }

    func test_pause_speaking() {
        viewModel.togglePlayPauseReview()
        XCTAssertEqual(viewModel.reviewStatus, .isPlaying)

        viewModel.pauseReview()
        XCTAssertEqual(viewModel.reviewStatus, .isPaused)
    }

    func test_stop_speaking() {
        viewModel.togglePlayPauseReview()
        XCTAssertEqual(viewModel.reviewStatus, .isPlaying)

        viewModel.stopReview()
        XCTAssertEqual(viewModel.reviewStatus, .unInitialized)
        XCTAssertNil(viewModel.lastPlayedQuestion)
    }

    func test_finished() {
        viewModel.finished()
        XCTAssertEqual(viewModel.reviewStatus, .unInitialized)
        XCTAssertNil(viewModel.lastPlayedQuestion)
    }

    func test_review_count() {
        viewModel.lastPlayedQuestion = viewModel.sorted.first!
        XCTAssertEqual(viewModel.reviewdCount, 1)

        viewModel.lastPlayedQuestion = nil
        XCTAssertEqual(viewModel.reviewdCount, 0)
    }

    override func tearDown() {
        viewModel = nil
    }
}
