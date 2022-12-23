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
    var question: Question

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
        question.question = questionString
        question.answer = answer
        question.detailDescription = detailDescription
        question.completed = completed

        if question.favorite == false, favorite {
            question.favoriteDate = Date()
        }
        question.favorite = favorite
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func insert() {
        withAnimation {
            question.question = self.questionString
            question.answer = answer
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
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func save() {
        if question.isInserted == false {
            saveEdit()
        } else {
            insert()
        }
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
}
