//
//  Leitner+CoreDataProperties.swift
//  
//
//  Created by hamed on 12/22/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Leitner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Leitner> {
        return NSFetchRequest<Leitner>(entityName: "Leitner")
    }

    @NSManaged public var backToTopLevel: Bool
    @NSManaged public var createDate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var level: NSSet?
    @NSManaged public var tag: NSSet?

}

// MARK: Generated accessors for level
extension Leitner {

    @objc(addLevelObject:)
    @NSManaged public func addToLevel(_ value: Level)

    @objc(removeLevelObject:)
    @NSManaged public func removeFromLevel(_ value: Level)

    @objc(addLevel:)
    @NSManaged public func addToLevel(_ values: NSSet)

    @objc(removeLevel:)
    @NSManaged public func removeFromLevel(_ values: NSSet)

}

// MARK: Generated accessors for tag
extension Leitner {

    @objc(addTagObject:)
    @NSManaged public func addToTag(_ value: Tag)

    @objc(removeTagObject:)
    @NSManaged public func removeFromTag(_ value: Tag)

    @objc(addTag:)
    @NSManaged public func addToTag(_ values: NSSet)

    @objc(removeTag:)
    @NSManaged public func removeFromTag(_ values: NSSet)

}

extension Leitner : Identifiable {

}
