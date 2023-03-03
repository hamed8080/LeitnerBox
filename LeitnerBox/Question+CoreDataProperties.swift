//
//  Question+CoreDataProperties.swift
//  LeitnerBox
//
//  Created by hamed on 3/3/23.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var question: String?
    @NSManaged public var answer: String?
    @NSManaged public var tagsCount: NSNumber?
    @NSManaged public var tag: NSSet?

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
