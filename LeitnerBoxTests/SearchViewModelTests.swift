//
// SearchViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
@testable import LeitnerBox
import SwiftUI
import XCTest

final class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!
    var mockContext: MockNSManagedObjectContext! = .init()

    override func setUp() {
        let mockSpeach = MockAVSpeechSynthesisVoice()
        let mockSynthesizer = MockAVSpeechSynthesizer()
        viewModel = SearchViewModel(viewContext: PersistenceController.shared.viewContext,
                                    leitner: ManagedObjectContextInstance.instance.leitners.first!,
                                    voiceSpeech: mockSpeach,
                                    synthesizer: mockSynthesizer)
    }

    func test_delete_items_with_offset() {
        let beforeCount = viewModel.questions.count
        viewModel.deleteItems(offsets: IndexSet(0 ..< 2))
        XCTAssertGreaterThan(beforeCount, viewModel.questions.count)
    }

    func test_delete_item() {
        let beforeCount = viewModel.questions.count
        viewModel.delete(viewModel.questions.first!)
        XCTAssertGreaterThan(beforeCount, viewModel.questions.count)
    }

    func test_sort() {
        viewModel.count = 500
        viewModel.sort(.level)
        XCTAssertTrue(viewModel.questions.first?.level?.level ?? 0 < viewModel.questions.last?.level?.level ?? 0)

        viewModel.sort(.completed)
        XCTAssertTrue(((viewModel.questions.first?.completed ?? false) ? 1 : 0) > ((viewModel.questions.last?.completed ?? false) ? 1 : 0))

        viewModel.sort(.alphabet)
        XCTAssertTrue(viewModel.questions.first?.question ?? "" < viewModel.questions.last?.question ?? "")

        viewModel.sort(.favorite)
        let top = ((viewModel.questions.first?.favorite ?? false) ? 1 : 0)
        let bottom = ((viewModel.questions.last?.favorite ?? false) ? 1 : 0)
        print(top, bottom)
        XCTAssertTrue(((viewModel.questions.first?.favorite ?? false) ? 1 : 0) > ((viewModel.questions.last?.favorite ?? false) ? 1 : 0))

        viewModel.sort(.passedTime)
        XCTAssertTrue(viewModel.questions.first?.passTime?.timeIntervalSince1970 ?? -1 > viewModel.questions.last?.passTime?.timeIntervalSince1970 ?? -1)

        viewModel.sort(.date)
        XCTAssertTrue(viewModel.questions.first?.createTime?.timeIntervalSince1970 ?? -1 > viewModel.questions.last?.createTime?.timeIntervalSince1970 ?? -1)

        viewModel.sort(.noTags)
        XCTAssertTrue(viewModel.questions.first?.tagsArray?.count ?? -1 <= viewModel.questions.last?.tagsArray?.count ?? -1)

        viewModel.sort(.tags)
        XCTAssertTrue(viewModel.questions.first?.tagsArray?.count ?? -1 >= viewModel.questions.last?.tagsArray?.count ?? -1)
    }

    func test_sorted_tags(){
        XCTAssertTrue(viewModel.sortedTags.first?.name ?? "" < viewModel.sortedTags.last?.name ?? "")
    }

    func test_toggle_completed() {
        let question = viewModel.questions.first!
        let beforeState = question.completed
        viewModel.toggleCompleted(question)
        let updated = viewModel.questions.first(where: { $0.objectID == question.objectID })!
        XCTAssertNotEqual(updated.completed, beforeState, "toggle completed not worked!")
    }

    func test_toggle_favorite() {
        let question = viewModel.questions.first!
        let beforeState = question.favorite
        viewModel.toggleFavorite(question)
        let updated = viewModel.questions.first(where: { $0.objectID == question.objectID })!
        XCTAssertNotEqual(updated.favorite, beforeState, "toggle favorite not worked!")
    }

    func test_reset_to_first_level() {
        let question = viewModel.questions.first(where: { $0.level?.level ?? 0 > 1 })!
        viewModel.resetToFirstLevel(question)
        let afterUpdate = viewModel.questions.first(where: { $0.objectID == question.objectID })
        XCTAssertEqual(afterUpdate?.levelValue ?? 0, 1, "Level didn't reset to first level")
        XCTAssertEqual(afterUpdate?.completed, false, "Completed didn't reset to false")
        XCTAssertNil(afterUpdate?.passTime, "Passed time is not nil")

        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "question == %@ AND leitnerId == %i AND levelValue == %i", question.question ?? "", viewModel.leitner.id, 1)
        let dbQuestions = try? viewModel.viewContext.fetch(req)
        let dbQuestion = dbQuestions?.first(where: {question.objectID == $0.objectID})
        XCTAssertEqual(dbQuestion?.level?.level ?? 0, 1, "Level didn't reset to first level")
        XCTAssertEqual(dbQuestion?.completed, false, "Completed didn't reset to false")
        XCTAssertNil(dbQuestion?.passTime, "Passed time is not nil")
    }

    func test_set_a_question_completed() {
        let question = viewModel.questions.first(where: { $0.level?.level ?? 0 > 1 })!
        viewModel.complete(question)
        let updated = viewModel.questions.first(where: { $0.objectID == question.objectID })!
        XCTAssertEqual(updated.level?.level ?? 0, 13, "Level didn't reset to completed level")
        XCTAssertEqual(updated.completed, true, "Level completed didn't reset to true")
        XCTAssertNotNil(updated.passTime, "Passed time is nil")
    }

    func test_filter() {
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.searchedQuestions.count, 0, "Search is not empty!")

        viewModel.searchText = "#"
        XCTAssertEqual(viewModel.searchedQuestions.count, 0, "Search is not empty")

        viewModel.searchText = "#Tag"
        XCTAssertGreaterThan(viewModel.searchedQuestions.count, 0, "Couldn't find any tag!")

        viewModel.searchText = "Question"
        XCTAssertGreaterThan(viewModel.searchedQuestions.count, 0, "Couldn't find any quetion!")

        viewModel.searchText = "Question"
        XCTAssertNil(viewModel.searchedQuestions.first(where: { $0.leitnerId != viewModel.leitner.id }), "You should only fetch questions on the same Leitner!")
    }

    func test_has_next() {
        viewModel.lastPlayedQuestion = viewModel.questions.first!
        XCTAssertTrue(viewModel.hasNext(), "The Array should have next Item!")
        // to retrive all questions inside a leitner which is around 60 in test environment
        viewModel.count = 500
        viewModel.fetchMoreQuestion()
        viewModel.lastPlayedQuestion = viewModel.questions.last!
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
        let beforeCount = viewModel.questions.count
        let leitner = LeitnerViewModel(viewContext: viewModel.viewContext).leitners.last!
        let question = viewModel.questions.first(where: { $0.completed == true })!
        viewModel.moveQuestionTo(question, leitner: leitner)

        let afterCount = viewModel.questions.count
        XCTAssertLessThan(afterCount, beforeCount)
        XCTAssertEqual(question.completed, false)
        XCTAssertEqual(question.passTime, nil)
        XCTAssertEqual(question.level?.level, 1)
        XCTAssertEqual(question.leitnerId, leitner.id)
    }

    func test_procounce_once() {
        viewModel.pronounceOnce(viewModel.questions.first!)
        XCTAssertFalse(viewModel.reviewStatus == .isPlaying)
    }

    func test_play_next() {
        viewModel.playNext()
        XCTAssertEqual(viewModel.reviewStatus, .unInitialized)

        viewModel.lastPlayedQuestion = viewModel.questions.first!
        viewModel.playNext()
        XCTAssertGreaterThanOrEqual(viewModel.questions.count, 1)
        XCTAssertNotNil(viewModel.lastPlayedQuestion)
    }

    func test_play_immediately() {
        viewModel.lastPlayedQuestion = viewModel.questions.first!
        let lastIndex = viewModel.questions.firstIndex(where: { $0 == viewModel.lastPlayedQuestion })
        viewModel.playNextImmediately()
        let newIndex = viewModel.questions.firstIndex(where: { $0 == viewModel.lastPlayedQuestion })
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
        viewModel.lastPlayedQuestion = viewModel.questions.first!
        XCTAssertEqual(viewModel.reviewdCount, 1)

        viewModel.lastPlayedQuestion = nil
        XCTAssertEqual(viewModel.reviewdCount, 0)
    }

    override func tearDown() {
        viewModel = nil
    }
}
