//
// LeitnerViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import Foundation
import SwiftUI

final class LeitnerViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContextProtocol
    @Published var leitners: [Leitner] = []
    @Published var showEditOrAddLeitnerAlert = false
    @Published var selectedLeitner: Leitner?
    @Published var settingSelected = false
    
    @Published var leitnerTitle: String = ""
    @Published var backToTopLevel = false
    @Published var selectedVoiceIdentifire: String?
    @Published var selectedObjectContainer: ObjectsContainer?
    @AppStorage("TopQuestionsForWidget", store: UserDefaults.group) var widgetQuestions: Data?

    init(viewContext: NSManagedObjectContextProtocol) {
        self.viewContext = viewContext
        selectedVoiceIdentifire = UserDefaults.standard.string(forKey: "selectedVoiceIdentifire")
        load()
        if selectedLeitner == nil, let firstLeitner = leitners.first {
            setLeithner(firstLeitner)
        }
    }

    func load() {
        do {
            let req = Leitner.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Leitner.createDate, ascending: true)]
            let leitners = try viewContext.fetch(req)
            let firstLeitnerId = leitners.first?.id ?? -1
            let wqs = Question.topWidgetQuestion(context: viewContext, leitnerId: firstLeitnerId)
            let data = try JSONEncoder().encode(wqs)
            self.leitners = leitners
            widgetQuestions = data
        } catch {
            print(error)
        }
    }

    func delete(_ leitner: Leitner) {
        if selectedLeitner?.id == leitner.id {
            // Switch navigation view to nil
            selectedLeitner = nil
        }
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
        let newItem = Leitner(context: viewContext as! NSManagedObjectContext)
        newItem.createDate = Date()
        newItem.name = leitnerTitle
        newItem.id = maxId + 1
        newItem.backToTopLevel = backToTopLevel
        let levels: [Level] = (1 ... 13).map { levelId in
            let level = Level(context: viewContext as! NSManagedObjectContext)
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
    
    func setLeithner(_ leitner: Leitner) {
        selectedLeitner = leitner
        selectedObjectContainer = ObjectsContainer(context: viewContext as! NSManagedObjectContext, leitner: leitner, leitnerVM: self)
    }
}
