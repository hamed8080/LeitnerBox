//
//  LeitnerBoxApp.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI

@main
struct LeitnerBoxApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
