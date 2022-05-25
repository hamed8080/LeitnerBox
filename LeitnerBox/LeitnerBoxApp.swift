//
//  LeitnerBoxApp.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI

@main
struct LeitnerBoxApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject
    var persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LeitnerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: scenePhase) { newPhase in
                                if newPhase == .active {
                                    PersistenceController.shared.replaceDBIfExistFromShareExtension()
                                } else if newPhase == .inactive {
                                    print("Inactive")
                                } else if newPhase == .background {
                                    print("Background")
                                }
                            }
        }
    }
}
