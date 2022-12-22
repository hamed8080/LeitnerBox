//
//  Statistic+CoreDataProperties.swift
//  
//
//  Created by hamed on 12/22/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Statistic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistic> {
        return NSFetchRequest<Statistic>(entityName: "Statistic")
    }

    @NSManaged public var actionDate: Date?
    @NSManaged public var isPassed: Bool
    @NSManaged public var question: Question?

}

extension Statistic : Identifiable {

}
