//
// Level+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation

extension Level {
    static func fetchReviewableCountInsideLevel(context: NSManagedObjectContextProtocol, level: Level, leitnerId: Int64) -> Int {
        let req = Question.fetchRequest()
        if let date = Calendar.current.date(byAdding: .day, value: -Int(level.daysToRecommend), to: .now) as? NSDate {
            req.predicate = NSPredicate(format: "level.leitner.id == %i AND completed == %@ AND level.level == %i AND (passTime <= %@ OR passTime = nil)", leitnerId, NSNumber(value: false), level.level, date)
            let reviewableCount = (try? context.count(for: req)) ?? 0
            return reviewableCount
        }
        return 0
    }

    static func fetchTotalCountInsideLevel(context: NSManagedObjectContextProtocol, level: Int16, leitnerId: Int64) -> Int {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.leitner.id == %i AND completed == %@ AND level.level == %i", leitnerId, NSNumber(value: false), level)
        let totalCount = (try? context.count(for: req)) ?? 0
        return totalCount
    }

    static func fetchCompletedCount(context: NSManagedObjectContextProtocol, leitnerId: Int64) -> Int {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.leitner.id == %i AND completed == %@", leitnerId, NSNumber(value: true))
        let completedCount = (try? context.count(for: req)) ?? 0
        return completedCount
    }

    static func fetchFavCountInsideLevel(context: NSManagedObjectContextProtocol, level: Int16, leitnerId: Int64) -> Int {
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.leitner.id == %i AND completed == %@ AND level.level == %i AND favorite == %@", leitnerId, NSNumber(value: false), level, NSNumber(value: true))
        let favCount = (try? context.count(for: req)) ?? 0
        return favCount
    }

    static func hasAnyReviewable(context: NSManagedObjectContextProtocol, level: Level, leitnerId: Int64) -> Bool {
        fetchReviewableCountInsideLevel(context: context, level: level, leitnerId: leitnerId) > 0
    }
}
