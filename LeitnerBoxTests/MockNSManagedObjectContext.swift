//
//  MockNSManagedObjectContext.swift
//  LeitnerBoxTests
//
//  Created by hamed on 7/6/22.
//

import Foundation
import CoreData
@testable import LeitnerBox

class MockNSManagedObjectContext<T:NSManagedObject>: NSManagedObjectContext{
    override func save() throws {
        throw MyError.FAIL_TO_SAVE
    }
}
