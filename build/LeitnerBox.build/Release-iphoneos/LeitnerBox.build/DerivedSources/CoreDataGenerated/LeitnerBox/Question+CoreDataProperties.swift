//
//  Question+CoreDataProperties.swift
//  
//
//  Created by hamed on 12/22/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var answer: String?
    @NSManaged public var completed: Bool
    @NSManaged public var createTime: Date?
    @NSManaged public var detailDescription: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var favoriteDate: Date?
    @NSManaged public var passTime: Date?
    @NSManaged public var question: String?
    @NSManaged public var level: Level?
    @NSManaged public var statistics: NSSet?
    @NSManaged public var synonyms: NSSet?
    @NSManaged public var tag: NSSet?

}

// MARK: Generated accessors for statistics
extension Question {

    @objc(addStatisticsObject:)
    @NSManaged public func addToStatistics(_ value: Statistic)

    @objc(removeStatisticsObject:)
    @NSManaged public func removeFromStatistics(_ value: Statistic)

    @objc(addStatistics:)
    @NSManaged public func addToStatistics(_ values: NSSet)

    @objc(removeStatistics:)
    @NSManaged public func removeFromStatistics(_ values: NSSet)

}

// MARK: Generated accessors for synonyms
extension Question {

    @objc(addSynonymsObject:)
    @NSManaged public func addToSynonyms(_ value: Synonym)

    @objc(removeSynonymsObject:)
    @NSManaged public func removeFromSynonyms(_ value: Synonym)

    @objc(addSynonyms:)
    @NSManaged public func addToSynonyms(_ values: NSSet)

    @objc(removeSynonyms:)
    @NSManaged public func removeFromSynonyms(_ values: NSSet)

}

// MARK: Generated accessors for tag
extension Question {

    @objc(addTagObject:)
    @NSManaged public func addToTag(_ value: Tag)

    @objc(removeTagObject:)
    @NSManaged public func removeFromTag(_ value: Tag)

    @objc(addTag:)
    @NSManaged public func addToTag(_ values: NSSet)

    @objc(removeTag:)
    @NSManaged public func removeFromTag(_ values: NSSet)

}

extension Question : Identifiable {

}
