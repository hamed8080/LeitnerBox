//
//  LeitnerBoxApp.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct LeitnerBoxApp: App, DropDelegate {
    
    
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject
    var persistenceController = PersistenceController.shared
    
    @State private var dragOver = false
    
    var body: some Scene {
        WindowGroup {
            LeitnerView()
                .onDrop(of: [.fileURL, .data], delegate: self)
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
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let proposal = DropProposal.init(operation: .copy)
        return proposal
    }
    
    func performDrop(info: DropInfo) -> Bool {
        PersistenceController.shared.dropDatabase(info)
        return true
    }
}
