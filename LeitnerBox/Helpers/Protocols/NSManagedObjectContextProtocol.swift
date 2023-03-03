//
//  NSManagedObjectContextProtocol.swift
//  LeitnerBox
//
//  Created by hamed on 2/24/23.
//

import CoreData
import Foundation

public protocol NSManagedObjectContextProtocol: AnyObject {
    var computedContext: NSManagedObjectContext { get }
    func save() throws
    func reset()
    func rollback()
    func refreshAllObjects()
    var insertedObjects: Set<NSManagedObject> { get }
    var updatedObjects: Set<NSManagedObject> { get }
    var deletedObjects: Set<NSManagedObject> { get }
    var registeredObjects: Set<NSManagedObject> { get }
    func insert(_ object: NSManagedObject)
    func delete(_ object: NSManagedObject)
    func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult
    func count<T>(for request: NSFetchRequest<T>) throws -> Int where T: NSFetchRequestResult
    var hasChanges: Bool { get }
    var name: String? { get }
}

extension NSManagedObjectContext: NSManagedObjectContextProtocol {
    public var computedContext: NSManagedObjectContext { self }
}
