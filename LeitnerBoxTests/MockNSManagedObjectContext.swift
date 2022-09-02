//
// MockNSManagedObjectContext.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/14/22.

import CoreData
import Foundation
@testable import LeitnerBox

class MockNSManagedObjectContext<T: NSManagedObject>: NSManagedObjectContext {
    override func save() throws {
        throw MyError.FAIL_TO_SAVE
    }
}
