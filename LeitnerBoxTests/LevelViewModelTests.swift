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

    override func setUp() {
        let leitner = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext).leitners.first!
        viewModel = LevelsViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner)
    }

    func test_filter() {
        viewModel.searchWord = ""
        XCTAssertTrue(viewModel.filtered.count == 0, "filter count is not equal all question!")

        viewModel.searchWord = "#"
        XCTAssertTrue(viewModel.filtered.count == 0, "empty tag is not equal all question!")

        viewModel.searchWord = "#Tag"
        XCTAssertTrue(viewModel.filtered.count > 0, "couldn't find any tag!")

        viewModel.searchWord = "Quesiton"
        XCTAssertTrue(viewModel.filtered.count > 0, "couldn't find any quetion!")
    }

    func test_edit_days_to_recommend() {
        viewModel.selectedLevel = viewModel.levels.first!
        viewModel.daysToRecommend = 365
        viewModel.saveDaysToRecommned()
        XCTAssertEqual(viewModel.levels.first(where: { $0.objectID == viewModel.selectedLevel?.objectID })?.daysToRecommend, 365)
    }

    func test_performance() {
        measure {
            viewModel.load()
        }
    }
}
