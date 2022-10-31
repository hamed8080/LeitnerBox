//
// TagViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class TagViewModelTests: XCTestCase {
    var vm: TagViewModel!

    override func setUp() {
        let leitner = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext).leitners.first!
        vm = TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner)
    }

    func test_delete_tag() {
        let tagsAtOffsets = vm.tags[0 ..< 2]
        vm.deleteItems(offsets: IndexSet(0 ..< 2))
        tagsAtOffsets.forEach { tag in
            XCTAssertFalse(vm.tags.contains(where: { $0.objectID == tag.objectID }), "Delete objects at offset not worked!")
        }
    }

    func test_add_new_tag() {
        vm.tagName = "NewTag"
        vm.colorPickerColor = .red
        vm.editOrAddTag()
        XCTAssertTrue(vm.tags.contains(where: { $0.name == "NewTag" }), "Tag not added")
    }

    func test_add_tag_to_question() {
        let newTag = Tag(context: vm.viewContext)
        newTag.name = "Test"
        vm.tags.append(newTag)
        if let tag = vm.tags.filter({ $0.question?.count ?? 0 > 0 }).first, let questions = (tag.question?.allObjects as? [Question]) {
            let firstQuestion = questions.first!
            let oldQuestionTagCounts = firstQuestion.tag?.count ?? 0
            vm.addToTag(newTag, firstQuestion)
            XCTAssertEqual(firstQuestion.tagsArray?.count ?? 0, oldQuestionTagCounts + 1, "Tags not added")
        }
    }

    func test_edit_tag() {
        let updateTagName = "Test UpdateTagName"
        XCTAssertFalse(vm.tags.contains(where: { $0.name == updateTagName }), "tag exist opps!")
        let firstTag = vm.tags.first!
        vm.selectedTag = firstTag
        vm.tagName = updateTagName
        vm.editOrAddTag()
        XCTAssertTrue(vm.tags.contains(where: { $0.name == updateTagName }), "Tag name is not updated.")
    }

    func test_clear() {
        vm.tagName = "Test"
        vm.colorPickerColor = .cyan
        vm.selectedTag = vm.tags.first
        vm.clear()
        XCTAssertTrue(vm.tagName.isEmpty, "tag name is not empty")
        XCTAssertNil(vm.selectedTag, "selected tag is not empty")
        XCTAssertTrue(vm.colorPickerColor == .gray, "color is not gray")
    }
}
