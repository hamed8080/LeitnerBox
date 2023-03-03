//
// LevelViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class LevelViewModelTests: XCTestCase {
    var viewModel: LevelsViewModel!
    var context = PersistenceController.shared.viewContext

    override func setUp() {
        let leitners = ManagedObjectContextInstance.instance.leitners
        viewModel = LevelsViewModel(viewContext: context, leitner: leitners.first!)
    }

    func test_filter() {
        viewModel.searchWord = ""
        XCTAssertTrue(viewModel.searchedQuestions.count == 0, "filter count is not equal all question!")

        viewModel.searchWord = "#"
        XCTAssertTrue(viewModel.searchedQuestions.count == 0, "empty tag is not equal all question!")

        viewModel.searchWord = "#Tag"
        XCTAssertTrue(viewModel.searchedQuestions.count > 0, "couldn't find any tag!")

        viewModel.searchedQuestions = []
        viewModel.searchWord = "Question"
        XCTAssertTrue(viewModel.searchedQuestions.count > 0, "couldn't find any quetion!")

        viewModel.searchedQuestions = []
        viewModel.searchWord = "Question"
        XCTAssertEqual(viewModel.searchedQuestions.first?.leitnerId, viewModel.leitner.id, "You should only fetch questions on the same Leitner!")

        viewModel.searchedQuestions = []
        viewModel.searchWord = "Question"
        XCTAssertNil(viewModel.searchedQuestions.first(where: { $0.leitnerId != viewModel.leitner.id }), "You should only fetch questions on the same Leitner!")
    }

    func test_fetch_questions() {
        viewModel.fetchQuestions("")
        XCTAssertTrue(viewModel.searchedQuestions.count == 0, "filter count is not equal all question!")

        viewModel.fetchQuestions("#")
        XCTAssertTrue(viewModel.searchedQuestions.count == 0, "empty tag is not equal all question!")

        viewModel.fetchQuestions("#Tag")
        XCTAssertTrue(viewModel.searchedQuestions.count > 0, "couldn't find any tag!")

        viewModel.searchedQuestions = []
        viewModel.fetchQuestions("Question")
        XCTAssertTrue(viewModel.searchedQuestions.count > 0, "couldn't find any quetion!")

        viewModel.searchedQuestions = []
        viewModel.fetchQuestions("Question")
        XCTAssertEqual(viewModel.searchedQuestions.first?.leitner?.id, viewModel.leitner.id, "You should only fetch questions on the same Leitner!")

        viewModel.searchedQuestions = []
        viewModel.fetchQuestions("Question")
        XCTAssertNil(viewModel.searchedQuestions.first(where: { $0.leitnerId != viewModel.leitner.id }), "You should only fetch questions on the same Leitner!")
    }

    func test_is_not_searching() {
        viewModel.searchWord = ""
        XCTAssertFalse(viewModel.isSearching, "The is searching have to be false when the searchWord is empty")
    }

    func test_is_not_searching_searched_questions_is_empty() {
        viewModel.searchWord = "Question" // To fill search quesiton
        viewModel.isSearching = false
        XCTAssertTrue(viewModel.searchedQuestions.count == 0, "The array should be empty when isSearching set to false by SwiftUI")
    }

    func test_is_searching_not_clear_array_if_had_filled() {
        viewModel.searchWord = "Question"
        viewModel.isSearching = true
        XCTAssertTrue(viewModel.searchedQuestions.count > 0, "The array should remain fill if any events of type isSearchin == true comes")
    }

    func test_edit_days_to_recommend() {
        viewModel.selectedLevel = viewModel.levels.first!.level
        viewModel.selectedLevel?.daysToRecommend = 365
        PersistenceController.saveDB(viewContext: context)
        XCTAssertEqual(viewModel.levels.first(where: { $0.level.objectID == viewModel.selectedLevel?.objectID })?.level.daysToRecommend, 365)
    }

    override func tearDown() {
        viewModel = nil
    }

    func test_performance() {
        let isCI = ProcessInfo.processInfo.environment["IS_CONTINUOUS_INTEGRATION"] == "1"
        if !isCI {
            measure {
                viewModel.load()
            }
        } else {
            XCTAssertTrue(true)
        }
    }
}
