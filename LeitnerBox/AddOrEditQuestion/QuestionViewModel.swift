//
// QuestionViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import CoreData
import Foundation
import SwiftUI

class QuestionViewModel: ObservableObject {
    @Published
    var viewContext: NSManagedObjectContext

    @Published
    var level: Level

    @Published
    var isManual = true

    @Published
    var isCompleted = false

    @Published
    var questions: [Question] = []

    @Published
    var answer: String = ""

    @Published
    var descriptionDetail: String = ""

    @Published
    var questionString: String = ""

    @Published
    var isFavorite: Bool = false

    @Published
    var question: Question

    @Published
    var isInEditMode: Bool = false

    init(viewContext: NSManagedObjectContext, level: Level, question: Question, isInEditMode: Bool) {
        self.viewContext = viewContext
        self.level = level
        self.question = question
        self.isInEditMode = isInEditMode
        if isInEditMode {
            setEditQuestionProperties(editQuestion: question)
        }
    }

    func saveEdit() {
        question.question = questionString
        question.answer = answer
        question.detailDescription = descriptionDetail
        question.completed = isCompleted

        if question.favorite == false, isFavorite {
            question.favoriteDate = Date()
        }
        question.favorite = isFavorite
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func insert() {
        withAnimation {
            question.question = self.questionString
            question.answer = answer
            question.detailDescription = self.descriptionDetail
            question.level = level
            question.completed = isCompleted

            if question.completed {
                if let lastLevel = level.leitner?.levels.first(where: { $0.level == 13 }) {
                    question.level = lastLevel
                    question.passTime = Date()
                    question.completed = true
                }
            }

            question.createTime = Date()
            question.favorite = isFavorite
            if question.favorite {
                question.favoriteDate = Date()
            }
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func save() {
        if isInEditMode {
            saveEdit()
        } else {
            clearUnsavedContextObjetcs()
            insert()
        }
    }

    /// For when user enter `AddQuestionView` and click `back` button, delete the `Quesiton(context: vm.viewContext)` from context to prevent `save` incorrectly if somewhere in the application save on the  `Context` get called.
    func clearUnsavedContextObjetcs() {
        viewContext.insertedObjects.forEach { object in
            if object != question {
                viewContext.delete(object)
            }
        }
    }

    func clear() {
        answer = ""
        questionString = ""
        isCompleted = false
        isManual = true
        descriptionDetail = ""
        isInEditMode = false
    }

    func setEditQuestionProperties(editQuestion: Question?) {
        if let editQuestion = editQuestion {
            isInEditMode = true
            question = editQuestion
            questionString = editQuestion.question ?? ""
            answer = editQuestion.answer ?? ""
            isCompleted = editQuestion.completed
            descriptionDetail = editQuestion.detailDescription ?? ""
            isFavorite = editQuestion.favorite
        }
    }
}
