//
// Leitner+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation
extension Leitner {
    var totalQuestionCount: Int {
        guard let levels = level?.allObjects as? [Level] else { return 0 }
        return levels.map { $0.questions?.count ?? 0 }.reduce(0, +)
    }

    var tagsArray: [Tag] {
        guard let tags = tag?.allObjects as? [Tag] else { return [] }
        return tags
    }

    var totalReviewableCount: Int {
        let levels = level?.allObjects as? [Level]
        let levelCountsArray = levels?.map { level in
            level.questions?.filter { ($0 as? Question)?.isReviewable ?? false }.count ?? 0
        }
        return levelCountsArray?.reduce(0, +) ?? 0
    }

    var succcessPercentage: Double {
        (Double(totalReviewableCount) / Double(totalQuestionCount)) * 100
    }

    var levels: [Level] {
        level?.allObjects as? [Level] ?? []
    }
    
    static func fetchLeitnerQuestionsCount(context: NSManagedObjectContextProtocol, leitnerId: Int64) -> Int {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.leitner.id == %i", leitnerId)
        let totalCount = (try? context.count(for: req)) ?? 0
        return totalCount
    }

    static func fetchLevelsInsideLeitner(context: NSManagedObjectContextProtocol, leitnerId: Int64) -> [Level] {
        let predicate = NSPredicate(format: "leitner.id == %d", leitnerId)
        let levelReq = Level.fetchRequest()
        levelReq.sortDescriptors = [NSSortDescriptor(keyPath: \Level.level, ascending: true)]
        levelReq.predicate = predicate
        let levels = (try? context.fetch(levelReq)) ?? []
        return levels
    }

    static func fetchLevelInsideLeitner(context: NSManagedObjectContextProtocol, leitnerId: Int64, level: Int64) -> Level? {
        let predicate = NSPredicate(format: "leitner.id == %d AND level == %i", leitnerId, level)
        let levelReq = Level.fetchRequest()
        levelReq.sortDescriptors = [NSSortDescriptor(keyPath: \Level.level, ascending: true)]
        levelReq.predicate = predicate
        let level = try? context.fetch(levelReq).first
        return level
    }

    static func fetchFavCount(context: NSManagedObjectContextProtocol, leitnerId: Int64) -> Int {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.leitner.id == %i AND favorite == %@", leitnerId, NSNumber(value: true))
        let favCount = (try? context.count(for: req)) ?? 0
        return favCount
    }
}
