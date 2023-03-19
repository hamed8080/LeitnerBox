//
// LeitnerBoxApp.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI
import AVFoundation

@main
struct LeitnerBoxApp: App, DropDelegate {
    @State private var dragOver = false
    @State var hideSplash = false

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
                ZStack {
                    LeitnerView()
                        .onDrop(of: [.fileURL, .data], delegate: self)
                        .environment(\.avSpeechSynthesisVoice, AVSpeechSynthesisVoice(identifier:  UserDefaults.standard.string(forKey: "selectedVoiceIdentifire") ?? "") ?? AVSpeechSynthesisVoice(language: "en-GB")!)
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .environmentObject(LeitnerViewModel(viewContext: PersistenceController.shared.container.viewContext))
                        .environmentObject(StatisticsViewModel(viewContext: PersistenceController.shared.container.viewContext))
                        .animation(.easeInOut, value: hideSplash)

                    UpdateDatabaseInBackground()
                }
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

struct UpdateDatabaseInBackground: View {
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        EmptyView()
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
