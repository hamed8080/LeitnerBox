//
//  Tag+CoreDataProperties.swift
//  
//
//  Created by hamed on 12/22/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var color: NSObject?
    @NSManaged public var name: String?
    @NSManaged public var leitner: Leitner?
    @NSManaged public var question: NSSet?

}

// MARK: Generated accessors for question
extension Tag {

    @objc(addQuestionObject:)
    @NSManaged public func addToQuestion(_ value: Question)

    @objc(removeQuestionObject:)
    @NSManaged public func removeFromQuestion(_ value: Question)

    @objc(addQuestion:)
    @NSManaged public func addToQuestion(_ values: NSSet)

    @objc(removeQuestion:)
    @NSManaged public func removeFromQuestion(_ values: NSSet)

}

extension Tag : Identifiable {

}
