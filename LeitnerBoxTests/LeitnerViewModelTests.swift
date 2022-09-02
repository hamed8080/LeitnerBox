//
// LeitnerViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/14/22.

@testable import LeitnerBox
import XCTest

final class LeitnerViewModelTests: XCTestCase {
    var vm: LeitnerViewModel!

    override func setUp() {
        vm = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext)
    }

    func test_load_method() {
        vm.load()
        XCTAssertTrue(vm.leitners.count >= 1, "Leitner is nil")
    }

    func test_clear_method() {
        vm.clear()
        XCTAssertEqual(vm.leitnerTitle, "")
        XCTAssertNil(vm.selectedLeitner)
        XCTAssertFalse(vm.backToTopLevel)
    }

    func test_add_leitner() {
        vm.leitnerTitle = "EnglishTest"
        vm.backToTopLevel = true
        let countBeforeAdd = vm.leitners.count
        vm.editOrAddLeitner()
        XCTAssertEqual(vm.leitners.count, countBeforeAdd + 1, "Add not worked!")
    }

    func test_edit_leitner() {
        let countBeforeAdd = vm.leitners.count
        let leitner = vm.leitners.first
        vm.selectedLeitner = leitner
        vm.leitnerTitle = "EnglishUpdated"
        vm.backToTopLevel = false
        vm.editOrAddLeitner()
        XCTAssertEqual(vm.leitners.count, countBeforeAdd, "Opps Added new `Item` instead of editing!")

        let updatedLeitner = vm.leitners.first(where: { $0.id == leitner?.id ?? 0 })
        XCTAssertEqual(updatedLeitner?.name, "EnglishUpdated")
        XCTAssertEqual(updatedLeitner?.backToTopLevel, false)
    }

    func test_delete_leitner() {
        let leitner = vm.leitners.first!
        vm.delete(leitner)
        XCTAssertFalse(vm.leitners.contains(where: { $0.id == leitner.id }))
    }

    func test_check_newId_for_leitner_added() {
        vm.leitners.removeAll()
        let firstLeitner = vm.makeNewLeitner()
        PersistenceController.saveDB(viewContext: vm.viewContext)
        XCTAssertEqual(firstLeitner.id, 1, "Expected to get id 1 whenever the leitner is empty")

        let lastId = vm.leitners.max(by: { $0.id < $1.id })?.id ?? 0
        vm.leitnerTitle = "EnglishTest"
        let newLeitner = vm.makeNewLeitner()
        XCTAssertEqual(newLeitner.id, lastId + 1, "Expected to add new item with higher id number!")
    }

    func test_fail_to_save() throws {
        let mockContext = MockNSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let notInContextLeitner = Leitner()
        vm.viewContext.delete(notInContextLeitner)
        PersistenceController.saveDB(viewContext: mockContext) { error in
            XCTAssertEqual(error, .FAIL_TO_SAVE)
        }
    }
}
