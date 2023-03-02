//
// TagViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
@testable import LeitnerBox
import SwiftUI
import XCTest

final class TagViewModelTests: XCTestCase {
    var viewModel: TagViewModel!
    var mockContext: MockNSManagedObjectContext! = .init()
    var context: NSManagedObjectContext = PersistenceController.shared.viewContext

    override func setUp() {
        viewModel = TagViewModel(viewContext: context, leitner: Leitner(context: context))
    }

    func test_delete_multiple_tags() {
        viewModel.loadMore()
        let tagsIndex = viewModel.tags.indices.prefix(2)
        let tags = viewModel.tags[tagsIndex]
        viewModel.deleteItems(offsets: IndexSet(tagsIndex.startIndex ..< tagsIndex.endIndex))
        tags.forEach { tag in
            XCTAssertFalse(viewModel.tags.contains(where: { $0.objectID == tag.objectID }), "Delete objects at offset not worked!")
        }
    }

    func test_add_new_tag() {
        viewModel.tagName = "NewTag"
        viewModel.colorPickerColor = UIColor(.red)
        viewModel.saveAddOrEdit()
        let req = Tag.fetchRequest()
        req.predicate = NSPredicate(format: "name = %@", "NewTag")
        let count = (try? context.count(for: req)) ?? 0
        XCTAssertTrue(count > 0, "Tag not added")
    }

    func test_add_tag_to_question() {
        let newTag = Tag(context: context)
        newTag.name = "Test"

        viewModel.tags.append(newTag)
        if let tag = viewModel.tags.filter({ $0.question?.count ?? 0 > 0 }).first, let questions = (tag.question?.allObjects as? [Question]) {
            let firstQuestion = questions.first!
            let oldQuestionTagCounts = firstQuestion.tag?.count ?? 0
            newTag.addToQuestion(firstQuestion)
            try? viewModel.viewContext.save()
            XCTAssertEqual(firstQuestion.tagsArray?.count ?? 0, oldQuestionTagCounts + 1, "Tags not added")
        }
    }

    func test_edit_tag() {
        viewModel.loadMore()
        let updateTagName = "Test UpdateTagName"
        XCTAssertFalse(viewModel.tags.contains(where: { $0.name == updateTagName }), "tag exist opps!")
        print("leitnerId: \(viewModel.leitner.id) , tagscount:\(viewModel.tags.count)")
        if let firstTag = viewModel.tags.first {
            viewModel.selectedTag = firstTag
            viewModel.tagName = updateTagName
            viewModel.saveAddOrEdit()
            XCTAssertTrue(viewModel.tags.contains(where: { $0.name == updateTagName }), "Tag name is not updated.")
        }
    }

    func test_clear() {
        viewModel.loadMore()
        viewModel.tagName = "Test"
        viewModel.colorPickerColor = UIColor(.cyan)
        viewModel.selectedTag = viewModel.tags.first
        viewModel.reset()
        XCTAssertTrue(viewModel.tagName.isEmpty, "tag name is not empty")
        XCTAssertNil(viewModel.selectedTag, "selected tag is not nil")
        XCTAssertNil(viewModel.colorPickerColor, "color is not nil")
    }

    func test_filter_when_search_text_changed() {
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filtered.count, 0, "Filter should be empty")

        viewModel.searchText = "Tag"
        XCTAssertTrue(viewModel.filtered.count > 0, "Filter array should not be empty.")
    }

    func test_search_tags() {
        viewModel.searchTags(text: "")
        XCTAssertTrue(viewModel.searchedTags.count == 0, "Search tags array is not empty.")

        viewModel.searchTags(text: "Tag")
        XCTAssertTrue(viewModel.searchedTags.count > 0, "Tag array should not be empty.")
    }

    func test_unique_name() {
        let uniqueString = UUID().uuidString
        let leitner = try? context.fetch(Leitner.fetchRequest()).first
        let beforeCount = (try? context.count(for: Tag.fetchRequest())) ?? 0

        let newTag = Tag(context: context)
        newTag.name = "Test\(uniqueString)"
        newTag.leitner = leitner

        let newTag2 = Tag(context: context)
        newTag2.name = "Test\(uniqueString)"
        newTag2.leitner = leitner
        try? context.save()

        let afterCount = (try? context.count(for: Tag.fetchRequest())) ?? 0
        XCTAssertLessThan(beforeCount, afterCount, "Two tags with the same name found.")
    }

    func test_throwing_load_more() {
        mockContext.error = MyError.failedLoadData
        let viewModel = TagViewModel(viewContext: mockContext, leitner: Leitner(context: context))
        viewModel.loadMore()
        XCTAssertEqual(viewModel.tags.count, 0, "when an error thrown we should append an empty array.")
    }

    func test_throwing_search() {
        mockContext.error = MyError.failedLoadData
        let viewModel = TagViewModel(viewContext: mockContext, leitner: Leitner(context: context))
        viewModel.searchTags(text: "Tag")
        XCTAssertEqual(viewModel.searchedTags.count, 0, "when an error thrown we should append an empty array.")
    }

    func test_no_load_when_han_next_is_false() {
        viewModel.hasNext = false
        viewModel.loadMore()
        XCTAssertEqual(viewModel.tags.count, 0, "There should be no more data when the hasNext property set to false.")
    }

    override func tearDown() {
        viewModel = nil
        mockContext = nil
    }
}
