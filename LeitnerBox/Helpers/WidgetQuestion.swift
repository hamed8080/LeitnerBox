//
// WidgetQuestion.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation
class WidgetQuestionTag: Codable, Identifiable {
    let name: String

    internal init(name: String) {
        self.name = name
    }
}

class WidgetQuestion: Codable {
    let question: String?
    let answer: String?
    let detailedDescription: String?
    let level: Int
    let isFavorite: Bool
    let isCompleted: Bool
    let tags: [WidgetQuestionTag]

    internal init(question: String?, answer: String?, tags: [WidgetQuestionTag], detailedDescription: String?, level: Int, isFavorite: Bool, isCompleted: Bool) {
        self.question = question
        self.answer = answer
        self.detailedDescription = detailedDescription
        self.level = level
        self.isFavorite = isFavorite
        self.isCompleted = isCompleted
        self.tags = tags
    }
}
