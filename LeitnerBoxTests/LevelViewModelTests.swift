//
// LevelViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class LevelViewModelTests: XCTestCase {
    var vm: LevelsViewModel!

    override func setUp() {
        let leitner = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext).leitners.first!
        vm = LevelsViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner)
    }

    func test_filter() {
        vm.searchWord = ""
        XCTAssertTrue(vm.filtered.count == 0, "filter count is not equal all question!")

        vm.searchWord = "#"
        XCTAssertTrue(vm.filtered.count == 0, "empty tag is not equal all question!")

        vm.searchWord = "#Tag"
        XCTAssertTrue(vm.filtered.count > 0, "couldn't find any tag!")

        vm.searchWord = "Quesiton"
        XCTAssertTrue(vm.filtered.count > 0, "couldn't find any quetion!")
    }

    func test_edit_days_to_recommend() {
        vm.selectedLevel = vm.levels.first!
        vm.daysToRecommend = 365
        vm.saveDaysToRecommned()
        XCTAssertEqual(vm.levels.first(where: { $0.objectID == vm.selectedLevel?.objectID })?.daysToRecommend, 365)
    }

    func test_performance() {
        measure {
            vm.load()
        }
    }
}
