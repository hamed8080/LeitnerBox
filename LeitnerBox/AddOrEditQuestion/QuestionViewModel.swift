//
// QuestionViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation
import SwiftUI

class QuestionViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContext
    @Published var level: Level
    @Published var isManual = true
    @Published var completed = false
    @Published var answer: String = ""
    @Published var detailDescription: String = ""
    @Published var questionString: String = ""
    @Published var favorite: Bool = false
    @Published var batchInserPhrasesMode = false
    var question: Question
    var title: String {
        if batchInserPhrasesMode {
            return "Batch Insert Phrases"
        } else if question.isInserted {
            return "Add New Question"
        } else {
            return "Edit Question"
        }
    }

    init(viewContext: NSManagedObjectContext, leitner: Leitner, question: Question? = nil) {
        self.viewContext = viewContext
        level = question == nil ? leitner.firstLevel! : question!.level!
        self.question = question ?? Question(context: viewContext)
        // Insert
        if question == nil {
            self.question.level = level
        } else {
            // Update
            setEditQuestionProperties(editQuestion: self.question)
        }
    }

    func saveEdit() {
        question.question = questionString.trimmingCharacters(in: .whitespacesAndNewlines)
        question.answer = answer
        question.leitner = level.leitner
        question.detailDescription = detailDescription
        question.completed = completed

        if question.favorite == false, favorite {
            question.favoriteDate = Date()
        }
        question.favorite = favorite
    }

    func insert(question: Question) {
        withAnimation {
            question.question = self.questionString.trimmingCharacters(in: .whitespacesAndNewlines)
            question.answer = answer
            question.leitner = level.leitner
            question.detailDescription = self.detailDescription
            question.level = level
            question.completed = completed

            if question.completed {
                if let lastLevel = level.leitner?.levels.first(where: { $0.level == 13 }) {
                    question.level = lastLevel
                    question.passTime = Date()
                    question.completed = true
                }
            }

            question.createTime = Date()
            question.favorite = favorite
            if question.favorite {
                question.favoriteDate = Date()
            }
        }
    }

    func batchInsertPhrases() {
        let phrases = splitPhrases()
        phrases.forEach { phrase in
            let newQuestion = Question(context: viewContext)
            insert(question: newQuestion)
            question.tagsArray?.forEach { tag in
                newQuestion.addToTag(tag)
            }
            question.synonymsArray?.forEach { synonym in
                newQuestion.addToSynonyms(synonym)
            }
            newQuestion.question = phrase
        }
    }

    func save() {
        if batchInserPhrasesMode {
            batchInsertPhrases()
        } else if question.isInserted == false {
            saveEdit()
        } else {
            insert(question: question)
        }
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func clear() {
        answer = ""
        questionString = ""
        completed = false
        isManual = true
        detailDescription = ""
    }

    func setEditQuestionProperties(editQuestion: Question) {
        question = editQuestion
        questionString = editQuestion.question ?? ""
        answer = editQuestion.answer ?? ""
        completed = editQuestion.completed
        detailDescription = editQuestion.detailDescription ?? ""
        favorite = editQuestion.favorite
    }

    func splitPhrases() -> [String] {
        questionString.split(separator: "\n").map { String($0) }
    }
}
