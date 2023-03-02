//
//  Question+CoreDataProperties.swift
//  LeitnerBox
//
//  Created by hamed on 3/2/23.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var question: String?

}

extension Question : Identifiable {

}
