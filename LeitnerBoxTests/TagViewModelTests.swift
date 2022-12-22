//
// TagViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

@testable import LeitnerBox
import SwiftUI
import XCTest

final class TagViewModelTests: XCTestCase {
    var viewModel: TagViewModel!

    override func setUp() {
        try? PersistenceController.shared.generateAndFillLeitner()
        let leitner = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext).leitners.first!
        viewModel = TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner)
    }

    func test_delete_tag() {
        let tagsAtOffsets = viewModel.tags[0 ..< 2]
        viewModel.deleteItems(offsets: IndexSet(0 ..< 2))
        tagsAtOffsets.forEach { tag in
            XCTAssertFalse(viewModel.tags.contains(where: { $0.objectID == tag.objectID }), "Delete objects at offset not worked!")
        }
    }

    func test_add_new_tag() {
        viewModel.tagName = "NewTag"
        viewModel.colorPickerColor = .red
        viewModel.editOrAddTag()
        XCTAssertTrue(viewModel.tags.contains(where: { $0.name == "NewTag" }), "Tag not added")
    }

    func test_add_tag_to_question() {
        let newTag = Tag(context: viewModel.viewContext)
        newTag.name = "Test"
        viewModel.tags.append(newTag)
        if let tag = viewModel.tags.filter({ $0.question?.count ?? 0 > 0 }).first, let questions = (tag.question?.allObjects as? [Question]) {
            let firstQuestion = questions.first!
            let oldQuestionTagCounts = firstQuestion.tag?.count ?? 0
            viewModel.addToTag(newTag, firstQuestion)
            XCTAssertEqual(firstQuestion.tagsArray?.count ?? 0, oldQuestionTagCounts + 1, "Tags not added")
        }
    }

    func test_edit_tag() {
        let updateTagName = "Test UpdateTagName"
        XCTAssertFalse(viewModel.tags.contains(where: { $0.name == updateTagName }), "tag exist opps!")
        let firstTag = viewModel.tags.first!
        viewModel.selectedTag = firstTag
        viewModel.tagName = updateTagName
        viewModel.editOrAddTag()
        XCTAssertTrue(viewModel.tags.contains(where: { $0.name == updateTagName }), "Tag name is not updated.")
    }

    func test_clear() {
        viewModel.tagName = "Test"
        viewModel.colorPickerColor = .cyan
        viewModel.selectedTag = viewModel.tags.first
        viewModel.clear()
        XCTAssertTrue(viewModel.tagName.isEmpty, "tag name is not empty")
        XCTAssertNil(viewModel.selectedTag, "selected tag is not empty")
        XCTAssertTrue(viewModel.colorPickerColor == .gray, "color is not gray")
    }
}
