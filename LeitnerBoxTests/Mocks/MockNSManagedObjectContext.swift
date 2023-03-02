//
// MockNSManagedObjectContext.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Combine
import CoreData
import Foundation
@testable import LeitnerBox

class MockNSManagedObjectContext: NSObject, NSManagedObjectContextProtocol {
    var error: Error?
    var fetchResult: [NSFetchRequestResult] = []
    var executeResult = NSPersistentStoreResult()
    var countResult: Int = 0

    var hasChanges: Bool = false
    var name: String?

    var insertedObjects = Set<NSManagedObject>()
    var updatedObjects = Set<NSManagedObject>()
    var deletedObjects = Set<NSManagedObject>()
    var registeredObjects = Set<NSManagedObject>()

    func save() throws {
        if let error {
            throw error
        }
    }

    func reset() {}

    func rollback() {}

    func refreshAllObjects() {}

    func insert(_: NSManagedObject) {}

    func delete(_: NSManagedObject) {}

    func execute(_: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        if let error {
            throw error
        }
        return executeResult
    }

    func fetch<T>(_: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult {
        if let error {
            throw error
        }
        return fetchResult as! [T]
    }

    func count<T>(for _: NSFetchRequest<T>) throws -> Int where T: NSFetchRequestResult {
        if let error {
            throw error
        }
        return countResult
    }
}
