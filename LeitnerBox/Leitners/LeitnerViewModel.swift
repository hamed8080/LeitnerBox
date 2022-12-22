//
// LeitnerViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import Foundation
import SwiftUI

class LeitnerViewModel: ObservableObject {
    @Published
    var viewContext: NSManagedObjectContext

    @Published
    var leitners: [Leitner] = []

    @Published
    var showEditOrAddLeitnerAlert = false

    @Published
    var selectedLeitner: Leitner?

    @Published
    var leitnerTitle: String = ""

    @Published
    var backToTopLevel = false

    @Published
    var backupFile: TemporaryFile?

    @Published
    var selectedVoiceIdentifire: String?

    @Published
    var voices: [AVSpeechSynthesisVoice] = []

    @Published
    var isBackuping = false

    @AppStorage("TopQuestionsForWidget", store: UserDefaults.group) var widgetQuestions: Data?

    init(viewContext: NSManagedObjectContext, voices: [AVSpeechSynthesisVoice] = AVSpeechSynthesisVoice.speechVoices().sorted(by: { $0.language > $1.language })) {
        self.viewContext = viewContext
        self.voices = voices
        selectedVoiceIdentifire = UserDefaults.standard.string(forKey: "selectedVoiceIdentifire")
        load()
    }

    func load() {
        let req = Leitner.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Leitner.createDate, ascending: true)]
        leitners = (try? viewContext.fetch(req)) ?? []

        let wqs = leitners.first?.allQuestions.prefix(200).map { question -> WidgetQuestion in
            let tags = question.tagsArray?.map { WidgetQuestionTag(name: $0.name ?? "") } ?? []
            let widegetQuestion = WidgetQuestion(question: question.question,
                                    answer: question.answer,
                                    tags: tags,
                                    detailedDescription: question.detailDescription,
                                    level: Int(question.level?.level ?? 1),
                                    isFavorite: question.favorite,
                                    isCompleted: question.completed)
            return widegetQuestion
        }
        if let wqs = wqs, let data = try? JSONEncoder().encode(wqs) {
            widgetQuestions = data
        }
    }

    func delete(_ leitner: Leitner) {
        if let index = leitners.firstIndex(where: { $0 == leitner }) {
            leitners.remove(at: index)
        }
        viewContext.delete(leitner)
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func editOrAddLeitner() {
        if selectedLeitner != nil {
            editLeitner()
        } else {
            addLeitner()
        }
    }

    func editLeitner() {
        selectedLeitner?.name = leitnerTitle
        selectedLeitner?.backToTopLevel = backToTopLevel
        PersistenceController.saveDB(viewContext: viewContext)
        showEditOrAddLeitnerAlert.toggle()
        if let selectedLeitner = selectedLeitner, let index = leitners.firstIndex(where: { $0.id == selectedLeitner.id }) {
            leitners[index] = selectedLeitner
        }
    }

    func addLeitner() {
        withAnimation {
            let newItem = makeNewLeitner()
            leitners.append(newItem)
            PersistenceController.saveDB(viewContext: viewContext)
            showEditOrAddLeitnerAlert.toggle()
            clear()
        }
    }

    func makeNewLeitner() -> Leitner {
        let maxId = leitners.max(by: { $0.id < $1.id })?.id ?? 0
        let newItem = Leitner(context: viewContext)
        newItem.createDate = Date()
        newItem.name = leitnerTitle
        newItem.id = maxId + 1
        newItem.backToTopLevel = backToTopLevel
        let levels: [Level] = (1 ... 13).map { levelId in
            let level = Level(context: viewContext)
            level.level = Int16(levelId)
            level.leitner = newItem
            level.daysToRecommend = Int32(levelId) * 2
            return level
        }
        newItem.level?.addingObjects(from: levels)
        return newItem
    }

    func clear() {
        leitnerTitle = ""
        backToTopLevel = false
        selectedLeitner = nil
    }

    func deleteBackupFile() async {
        try? backupFile?.deleteDirectory()
        await MainActor.run {
            backupFile = nil
        }
    }
    func exportDB() async {
        await MainActor.run {
            isBackuping = true
        }
        let backupStoreOptions: [AnyHashable: Any] = [
            NSReadOnlyPersistentStoreOption: true,
            // Disable write-ahead logging. Benefit: the entire store will be
            // contained in a single file. No need to handle -wal/-shm files.
            // https://developer.apple.com/library/content/qa/qa1809/_index.html
            NSSQLitePragmasOption: ["journal_mode": "DELETE"],
            // Minimize file size
            NSSQLiteManualVacuumOption: true
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
            await MainActor.run {
                isBackuping = false
                self.backupFile = backupFile
            }
            print("file exported to\(backupFile.fileURL)")
        } catch {
            print("failed to export: Error \(error.localizedDescription)")
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
        selectedVoiceIdentifire = voice.identifier
        UserDefaults.standard.set(selectedVoiceIdentifire, forKey: "selectedVoiceIdentifire")
    }

    func fillWidgetTopQuestions() {}
}
