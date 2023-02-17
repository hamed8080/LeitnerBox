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
        let leitners = try? PersistenceController.shared.generateAndFillLeitner()
        viewModel = LevelsViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitners!.first!)
    }

    func test_filter() {
        viewModel.searchWord = ""
        XCTAssertTrue(viewModel.levels.count == 0, "filter count is not equal all question!")

        viewModel.searchWord = "#"
        XCTAssertTrue(viewModel.filtered.count == 0, "empty tag is not equal all question!")

        viewModel.searchWord = "#Tag"
        XCTAssertTrue(viewModel.filtered.count > 0, "couldn't find any tag!")

        viewModel.searchWord = "Quesiton"
        XCTAssertTrue(viewModel.filtered.count > 0, "couldn't find any quetion!")
    }

    func test_edit_days_to_recommend() {
        viewModel.selectedLevel = viewModel.levels.first!
        viewModel.selectedLevel?.daysToRecommend = 365
        PersistenceController.saveDB(viewContext: PersistenceController.shared.viewContext)
        XCTAssertEqual(viewModel.levels.first(where: { $0.objectID == viewModel.selectedLevel?.objectID })?.daysToRecommend, 365)
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
