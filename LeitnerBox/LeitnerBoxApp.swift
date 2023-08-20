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
    var isUnitTesting = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_TEST"] == "1"

    var body: some Scene {
        let context = PersistenceController.shared.container.viewContext
        WindowGroup {
            ZStack {
                if isUnitTesting {
                    Text("In Unit Testing")
                } else if hideSplash == false {
                    SplashScreen()
                } else {
                    LeitnerView(context: context)
                    UpdateDatabaseInBackground()
                }
            }
            .onDrop(of: [.fileURL, .data], delegate: self)
            .environment(\.avSpeechSynthesisVoice, AVSpeechSynthesisVoice(identifier:  UserDefaults.standard.string(forKey: "selectedVoiceIdentifire") ?? "") ?? AVSpeechSynthesisVoice(language: "en-GB")!)
            .environment(\.managedObjectContext, context)
            .environmentObject(LeitnerViewModel(viewContext: context))
            .environmentObject(StatisticsViewModel(viewContext: context))
            .animation(.easeInOut, value: hideSplash)
            .onAppear {
                if !isUnitTesting {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        hideSplash = true
                    }
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
