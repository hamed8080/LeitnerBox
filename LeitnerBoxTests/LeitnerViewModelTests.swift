//
// LeitnerViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

@testable import LeitnerBox
import XCTest

final class LeitnerViewModelTests: XCTestCase {
    var viewModel: LeitnerViewModel!

    override func setUp() {
        viewModel = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)
    }

    func test_load_method() {
        viewModel.load()
        XCTAssertTrue(viewModel.leitners.count >= 1, "Leitner is nil")
    }

    func test_clear_method() {
        viewModel.clear()
        XCTAssertEqual(viewModel.leitnerTitle, "")
        XCTAssertNil(viewModel.selectedLeitner)
        XCTAssertFalse(viewModel.backToTopLevel)
    }

    func test_add_leitner() {
        viewModel.leitnerTitle = "EnglishTest"
        viewModel.backToTopLevel = true
        let countBeforeAdd = viewModel.leitners.count
        viewModel.editOrAddLeitner()
        XCTAssertEqual(viewModel.leitners.count, countBeforeAdd + 1, "Add not worked!")
    }

    func test_edit_leitner() {
        let countBeforeAdd = viewModel.leitners.count
        let leitner = viewModel.leitners.first
        viewModel.selectedLeitner = leitner
        viewModel.leitnerTitle = "EnglishUpdated"
        viewModel.backToTopLevel = false
        viewModel.editOrAddLeitner()
        XCTAssertEqual(viewModel.leitners.count, countBeforeAdd, "Opps Added new `Item` instead of editing!")

        let updatedLeitner = viewModel.leitners.first(where: { $0.id == leitner?.id ?? 0 })
        XCTAssertEqual(updatedLeitner?.name, "EnglishUpdated")
        XCTAssertEqual(updatedLeitner?.backToTopLevel, false)
    }

    func test_delete_leitner() {
        let leitner = viewModel.leitners.first!
        viewModel.delete(leitner)
        XCTAssertFalse(viewModel.leitners.contains(where: { $0 == leitner }))
    }

    func test_check_newId_for_leitner_added() {
        viewModel.leitners.removeAll()
        let firstLeitner = viewModel.makeNewLeitner()
        PersistenceController.saveDB(viewContext: viewModel.viewContext)
        XCTAssertEqual(firstLeitner.id, 1, "Expected to get id 1 whenever the leitner is empty")

        let lastId = viewModel.leitners.max(by: { $0.id < $1.id })?.id ?? 0
        viewModel.leitnerTitle = "EnglishTest"
        let newLeitner = viewModel.makeNewLeitner()
        XCTAssertEqual(newLeitner.id, lastId + 1, "Expected to add new item with higher id number!")
    }

    func test_fail_to_save() throws {
        let mockContext = MockNSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let notInContextLeitner = Leitner()
        viewModel.viewContext.delete(notInContextLeitner)
        PersistenceController.saveDB(viewContext: mockContext) { error in
            XCTAssertEqual(error, .failToSave)
        }
    }
}
