//
//  Level+CoreDataProperties.swift
//  
//
//  Created by hamed on 12/22/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Level {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Level> {
        return NSFetchRequest<Level>(entityName: "Level")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var daysToRecommend: Int32
    @NSManaged public var level: Int16
    @NSManaged public var leitner: Leitner?
    @NSManaged public var questions: NSSet?

}

// MARK: Generated accessors for questions
extension Level {

    @objc(addQuestionsObject:)
    @NSManaged public func addToQuestions(_ value: Question)

    @objc(removeQuestionsObject:)
    @NSManaged public func removeFromQuestions(_ value: Question)

    @objc(addQuestions:)
    @NSManaged public func addToQuestions(_ values: NSSet)

    @objc(removeQuestions:)
    @NSManaged public func removeFromQuestions(_ values: NSSet)

}

extension Level : Identifiable {

}
