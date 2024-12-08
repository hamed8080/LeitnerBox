//
// Question+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation

extension Question {
    var isReviewable: Bool {
        guard let passTime = passTime else { return true }
        let daysToRecommend = level?.daysToRecommend ?? 0
        return passTime.advanced(by: Double(daysToRecommend * (24 * 3600))) <= Date() && completed == false
    }

    var remainDays: String {
        let daysToRecommend = level?.daysToRecommend ?? 0
        if let passTime, passTime.advanced(by: Double(daysToRecommend * (24 * 3600))) >= Date() {
            let components = passTime.advanced(by: Double(daysToRecommend * (24 * 3600))).differenceWith(from: Date())

            let days = (components.day ?? 0)
            let daysString = days > 0 ? "\(days) days " : ""
            let hours = components.hour ?? 0
            let hoursString = hours > 0 ? " \(hours) hours " : ""
            let minutes = components.minute ?? 0
            let minutesString = minutes > 0 ? " \(minutes) minutes " : ""
            return "\(daysString)\(hoursString)\(minutesString) left".uppercased()
        } else {
            return "Available".uppercased()
        }
    }

    static func topWidgetQuestion(context: NSManagedObjectContextProtocol, leitnerId: Int64) -> [WidgetQuestion] {
        let req = Question.fetchRequest()
        req.fetchLimit = 10
        req.predicate = NSPredicate(format: "level.leitner.id == %i", leitnerId)
        let topQuestions = (try? context.fetch(req)) ?? []
        var wqs: [WidgetQuestion] = []
        topQuestions.forEach { question in
            let tags = question.tagsArray?.map { WidgetQuestionTag(name: $0.name ?? "") } ?? []
            let widegetQuestion = WidgetQuestion(question: question.question,
                                                 answer: question.answer,
                                                 tags: tags,
                                                 detailedDescription: question.detailDescription,
                                                 level: Int(question.level?.level ?? 1),
                                                 isFavorite: question.favorite,
                                                 isCompleted: question.completed)
            wqs.append(widegetQuestion)
        }
        return wqs
    }

    var upperLevel: Level? {
        let levels = level?.leitner?.levels
        return levels?.filter { (level?.level ?? 0) + 1 == $0.level }.first
    }

    var firstLevel: Level? {
        let levels = level?.leitner?.levels
        return levels?.filter { $0.level == 1 }.first
    }

    var tagsArray: [Tag]? {
        tag?.allObjects as? [Tag]
    }
    
    var imagesArray: [ImageURL]? {
        images?.allObjects as? [ImageURL]
    }

    var synonymsArray: [Question]? {
        guard let synonym = (synonyms?.allObjects as? [Synonym])?.first else { return nil }
        return synonym.question?.allObjects as? [Question]
    }
}
