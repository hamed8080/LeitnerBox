//
// Persistence.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

class PersistenceController: ObservableObject {
    static var shared = PersistenceController()
    var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    var container: NSPersistentCloudKitContainer

    private init() {
        container = NSPersistentCloudKitContainer(name: "LeitnerBox")
        guard let url = container.persistentStoreDescriptions.first?.url else { return }
        let opt = [NSInferMappingModelAutomaticallyOption: false, NSMigratePersistentStoresAutomaticallyOption: true]
        _ = try? container.persistentStoreCoordinator.addPersistentStore(type: .sqlite, at: url, options: opt)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
