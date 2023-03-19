//
// QuestionViewModelTests.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

 @testable import LeitnerBox
 import SwiftUI
 import XCTest

 final class QuestionViewModelTests: XCTestCase {
    var viewModel: QuestionViewModel!

    override func setUp() {
        let leitner = ManagedObjectContextInstance.instance.leitners.first!
        let viewContext = PersistenceController.shared.viewContext
        viewModel = QuestionViewModel(viewContext: viewContext, leitner: leitner)
    }

    func test_save_edit() async {
        let question = findQuestion(leitnerId: viewModel.leitner.id, level: 1)
        let viewModel = QuestionViewModel(viewContext: viewModel.viewContext, leitner: viewModel.leitner, question: question)
        viewModel.questionString = "Updated question"
        viewModel.completed = true
        viewModel.answer = "Answer updated"
        viewModel.favorite = true
        viewModel.detailDescription = "Updated detail description"
        viewModel.saveEdit()

        let updated = findQuestion(leitnerId: viewModel.leitner.id, question: question?.question, level: 1)
        XCTAssertEqual(updated?.completed, question?.completed)
        XCTAssertEqual(updated?.favoriteDate?.timeIntervalSince1970, question?.favoriteDate?.timeIntervalSince1970)
        XCTAssertEqual(updated?.answer, question?.answer)
        XCTAssertEqual(updated?.question, question?.question)
        XCTAssertEqual(updated?.detailDescription, question?.detailDescription)
        XCTAssertEqual(updated?.favorite, question?.favorite)
    }

    func test_insert() {
        let viewModel = QuestionViewModel(viewContext: viewModel.viewContext, leitner: viewModel.leitner)
        viewModel.questionString = "New Question\(UUID().uuidString)"
        viewModel.answer = "Answer"
        viewModel.detailDescription = "Descrition"
        viewModel.completed = true
        viewModel.favorite = true
        viewModel.save()
        let inserted = findQuestion(leitnerId: viewModel.leitner.id, question: viewModel.questionString, level: 13)
        XCTAssertEqual(inserted?.completed, viewModel.completed)
        XCTAssertEqual(inserted?.answer, viewModel.answer)
        XCTAssertEqual(inserted?.question, viewModel.questionString)
        XCTAssertEqual(inserted?.detailDescription, viewModel.detailDescription)
        XCTAssertEqual(inserted?.favorite, viewModel.favorite)
        XCTAssertNotNil(inserted?.favoriteDate?.timeIntervalSince1970)
    }
//
//    func test_save() {
//        let viewContext = PersistenceController.shared.viewContext
//        let leitner = LeitnerViewModel(viewContext: viewContext).leitners.first!
//        viewModel = QuestionViewModel(viewContext: viewContext, leitner: leitner, question: nil)
//        let insertObjectCount = viewContext.insertedObjects.count
//        viewModel.answer = "New Question"
//        viewModel.save()
//        let afterSaveObjectCount = viewContext.insertedObjects.count
//        XCTAssertNotEqual(insertObjectCount, afterSaveObjectCount, "Number of elements should not be equal after save the insertion.")
//    }
//
//    func test_save_update() {
//        let question = viewModel.level.allQuestions.first!
//        viewModel.question = question
//        viewModel.answer = "Updated answer"
//        viewModel.save()
//        XCTAssertEqual(question.answer, "Updated answer")
//    }

     func test_set_edit_mode_fill_text_fields() {
         let question = findQuestion(leitnerId: viewModel.leitner.id, level: 1)
         let viewModel = QuestionViewModel(viewContext: viewModel.viewContext, leitner: viewModel.leitner, question: question)

         XCTAssertNotNil(viewModel.question)
         XCTAssertEqual(viewModel.favorite, question?.favorite)
         XCTAssertEqual(viewModel.completed, question?.completed)
         XCTAssertEqual(viewModel.answer, question?.answer)
         XCTAssertEqual(viewModel.questionString, question?.question)
         XCTAssertEqual(viewModel.detailDescription, question?.detailDescription ?? "")
     }

    func test_rest_clear_all_text_fields() {
        let question = findQuestion(leitnerId: viewModel.leitner.id, level: 1)
        let viewModel = QuestionViewModel(viewContext: viewModel.viewContext, leitner: viewModel.leitner, question: question)
        viewModel.reset()

        XCTAssertEqual(viewModel.isManual, true)
        XCTAssertEqual(viewModel.favorite, false)
        XCTAssertEqual(viewModel.completed, false)
        XCTAssertTrue(viewModel.answer == "")
        XCTAssertTrue(viewModel.questionString == "")
        XCTAssertTrue(viewModel.detailDescription == "")
        XCTAssertEqual(viewModel.tags.count, 0)
        XCTAssertEqual(viewModel.synonyms.count, 0)
    }

    func test_split_pharases() {
        setPhrases()
        let splited = viewModel.splitPhrases()
        XCTAssertEqual(splited.count, 3, "Splitting problem there should be 3 item in the list")
    }

    func setPhrases() {
        let phrases = """
        Word World
        Test
        Hello Daday
        """
        viewModel.questionString = phrases
    }

     func test_add_pharases() {
         let beforeCount = viewModel.viewContext.insertedObjects.count
         setPhrases()
         viewModel.batchInsertPhrases()
         let afterCount = beforeCount + viewModel.splitPhrases().count
         XCTAssertGreaterThan(afterCount, beforeCount, "Insert does not work.")
     }

     func findQuestion(leitnerId: Int64?, question: String?, level: Int) -> Question? {
         let req = Question.fetchRequest()
         req.predicate = NSPredicate(format: "question == %@ AND leitnerId == %i AND levelValue == %i", question ?? "", leitnerId ?? -1, level)
         let dbQuestions = try? viewModel.viewContext.fetch(req)
         return dbQuestions?.first
     }

     func findQuestion(leitnerId: Int64?, level: Int, completed: Bool = false) -> Question? {
         let req = Question.fetchRequest()
         req.predicate = NSPredicate(format: "leitnerId == %i AND levelValue == %i AND completed == %@", leitnerId ?? -1, level, NSNumber(booleanLiteral: completed))
         let dbQuestions = try? viewModel.viewContext.fetch(req)
         return dbQuestions?.first
     }

     override func tearDown() {
         viewModel = nil
     }
 }
