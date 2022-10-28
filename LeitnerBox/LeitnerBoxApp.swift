//
// LeitnerBoxApp.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

@main
struct LeitnerBoxApp: App, DropDelegate {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject
    var persistenceController = PersistenceController.shared

    @ObservedObject
    var leitnerVM = LeitnerViewModel(viewContext: PersistenceController.shared.container.viewContext)

    @ObservedObject
    var statVM = StatisticsViewModel()

    @State private var dragOver = false
    @State
    var hideSplash = false

    var body: some Scene {
        WindowGroup {
            if hideSplash == false {
                SplashScreen()
                    .animation(.easeInOut, value: hideSplash)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            hideSplash = true
                        }
                    }
            } else {
                LeitnerView()
                    .onDrop(of: [.fileURL, .data], delegate: self)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(leitnerVM)
                    .environmentObject(statVM)
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                            PersistenceController.shared.replaceDBIfExistFromShareExtension()
                        } else if newPhase == .inactive {
                            print("Inactive")
                        } else if newPhase == .background {
                            print("Background")
                        }
                    }
                    .animation(.easeInOut, value: hideSplash)
            }
        }
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        let proposal = DropProposal(operation: .copy)
        return proposal
    }

    func performDrop(info: DropInfo) -> Bool {
        PersistenceController.shared.dropDatabase(info)
        return true
    }
}
