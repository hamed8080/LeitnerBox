//
// SettingsViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var backToTopLevel = false
    @Published var backupFile: TemporaryFile?
    @Published var selectedVoiceIdentifire: String?
    @Published var isBackuping = false
    @Published var selectedVoice: AVSpeechSynthesisVoice
    let voices = AVSpeechSynthesisVoice.speechVoices().sorted(by: { $0.language > $1.language })

    init() {
        let selectedVoiceIdentifire = UserDefaults.standard.string(forKey: "selectedVoiceIdentifire")
        if let selectedVoiceIdentifire, let selectedVoice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifire) {
            self.selectedVoice = selectedVoice
        } else {
            selectedVoice = voices.first!
        }
    }

    func deleteBackupFile() async {
        try? backupFile?.deleteDirectory()
        await MainActor.run {
            backupFile = nil
        }
    }

    func exportDB() async {
        await showLoading(show: true)
        let backupStoreOptions: [AnyHashable: Any] = [
            NSReadOnlyPersistentStoreOption: true,
            // Disable write-ahead logging. Benefit: the entire store will be
            // contained in a single file. No need to handle -wal/-shm files.
            // https://developer.apple.com/library/content/qa/qa1809/_index.html
            NSSQLitePragmasOption: ["journal_mode": "DELETE"],
            // Minimize file size
            NSSQLiteManualVacuumOption: true,
        ]
        guard let sourcePersistentStore = PersistenceController.shared.container.persistentStoreCoordinator.persistentStores.first else { return }
        let managedObjectModel = PersistenceController.shared.container.managedObjectModel
        let backupPersistentContainer = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let intermediateStoreOptions = (sourcePersistentStore.options ?? [:]).merging([NSReadOnlyPersistentStoreOption: true], uniquingKeysWith: { $1 })
        do {
            let newPersistentStore = try backupPersistentContainer.addPersistentStore(
                ofType: sourcePersistentStore.type,
                configurationName: sourcePersistentStore.configurationName,
                at: sourcePersistentStore.url,
                options: intermediateStoreOptions
            )

            let exportFile = makeFilename(sourcePersistentStore)
            let backupFile = try TemporaryFile(creatingTempDirectoryForFilename: exportFile)
            try backupPersistentContainer.migratePersistentStore(newPersistentStore, to: backupFile.fileURL, options: backupStoreOptions, withType: NSSQLiteStoreType)
            await showLoading(show: false)
            await MainActor.run {
                self.backupFile = backupFile
            }
            print("file exported to\(backupFile.fileURL)")
        } catch {
            await showLoading(show: false)
            print("failed to export: Error \(error.localizedDescription)")
        }
    }

    func showLoading(show: Bool) async {
        await MainActor.run {
            isBackuping = show
        }
    }

    func importDB() {}

    // Filename format: basename-date.sqlite
    // E.g. "MyStore-20180221T200731.sqlite" (time is in UTC)
    func makeFilename(_ sourceStore: NSPersistentStore) -> String {
        let basename = sourceStore.url?.deletingPathExtension().lastPathComponent ?? "store-backup"
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime]
        let dateString = dateFormatter.string(from: Date())
        return "\(basename)-\(dateString).sqlite"
    }

    func setSelectedVoice(_ voice: AVSpeechSynthesisVoice) {
        selectedVoice = voice
        selectedVoiceIdentifire = voice.identifier
        UserDefaults.standard.set(selectedVoiceIdentifire, forKey: "selectedVoiceIdentifire")
    }

    func fillWidgetTopQuestions() {}
}
