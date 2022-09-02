//
// LevelEX.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/14/22.

import Foundation
extension Level {
    var reviewableCountInsideLevel: Int {
        let questions = questions?.allObjects as? [Question]
        let reviewableCount = questions?.filter { $0.isReviewable && $0.completed == false }.count
        return reviewableCount ?? 0
    }

    var hasAnyReviewable: Bool {
        let questions = questions?.allObjects as? [Question]
        let reviewableCount = questions?.filter { $0.isReviewable && $0.completed == false }.count ?? 0
        return reviewableCount > 0
    }

    var notCompletdCount: Int {
        let questions = questions?.allObjects as? [Question]
        return questions?.filter { $0.completed == false }.count ?? 0
    }

    var allQuestions: [Question] {
        questions?.allObjects as? [Question] ?? []
    }
}
