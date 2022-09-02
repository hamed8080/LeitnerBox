//
// LeitnerEX.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import CoreData
import Foundation
extension Leitner {
    var totalQuestionCount: Int {
        guard let levels = level?.allObjects as? [Level] else { return 0 }
        return levels.map { $0.questions?.count ?? 0 }.reduce(0,+)
    }

    var tagsArray: [Tag] {
        guard let tags = tag?.allObjects as? [Tag] else { return [] }
        return tags
    }

    var levels: [Level] {
        level?.allObjects as? [Level] ?? []
    }

    var allQuestions: [Question] {
        let allQuestionInEachLevels = levels.map(\.allQuestions)
        var arr: [Question] = []
        allQuestionInEachLevels.forEach { questionsInLevel in
            arr.append(contentsOf: questionsInLevel)
        }
        return arr
    }

    var firstLevel: Level? {
        levels.first(where: { $0.level == 1 })
    }

    func findQuestion(objectID: NSManagedObjectID?) -> Question? {
        guard let objectID = objectID else { return nil }
        return allQuestions.first(where: { $0.objectID == objectID })
    }
}
