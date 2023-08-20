//
// SettingsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @State private var showBackupSheet = false
    @AppStorage("pronounceDetailAnswer") private var pronounceDetailAnswer = false

    var body: some View {
        Form {
            Section(String(localized: .init("Voice"))) {
                Toggle(isOn: $pronounceDetailAnswer) {
                    Label("Prononce details of an answer ", systemImage: "mic")
                }

                Menu {
                    ForEach(viewModel.voices, id: \.self) { voice in
                        Button {
                            viewModel.setSelectedVoice(voice)
                        } label: {
                            let isSelected = viewModel.selectedVoice.identifier == voice.identifier
                            Text("\(isSelected ? "✔︎" : "") \(voice.name) - \(voice.language)")
                        }
                    }
                } label: {
                    HStack {
                        Label("Pronounce Voice", systemImage: "waveform")
                        Spacer()
                        Text("\(viewModel.selectedVoice.name) - \(viewModel.selectedVoice.language)")
                    }
                }
            }

            Section(String(localized: .init("Backup"))) {
                Button {
                    Task {
                        await viewModel.exportDB()
                    }
                } label: {
                    if viewModel.isBackuping {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accentColor)
                    } else {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .onChange(of: viewModel.backupFile?.fileURL) { newValue in
            if let newValue {
                showBackupSheet = true
            }
        }
        .sheet(isPresented: $showBackupSheet) {
            if .iOS == true {
                Task {
                    await viewModel.deleteBackupFile()
                }
            }
        } content: {
            if let fileUrl = viewModel.backupFile?.fileURL {
                ActivityViewControllerWrapper(activityItems: [fileUrl])
            } else {
                EmptyView()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var viewModel = SettingsViewModel()

        var body: some View {
            SettingsView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
        .previewDisplayName("SettingsView")
    }
}
