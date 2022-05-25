//
//  LeitnerViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

class LeitnerViewModel:ObservableObject{
    
    @Published
    var viewContext:NSManagedObjectContext

    @Published
    var leitners: [Leitner] = []
    
    @Published
    var showEditOrAddLeitnerAlert = false
    
    @Published
    var selectedLeitner:Leitner? = nil
    
    @Published
    var leitnerTitle:String = ""
    
    @Published
    var backToTopLevel = false
    
    @Published
    var showBackupFileShareSheet = false
    
    @Published
    var backupFile:TemporaryFile? = nil
    
    @Published
    var selectedVoiceIdentifire:String? = nil
    
    @Published
    var voices:[AVSpeechSynthesisVoice] = []
    
    init(isPreview:Bool = false){
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        let req = Leitner.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Leitner.createDate, ascending: true)]
        do {
            self.leitners = try viewContext.fetch(req)
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
        voices = AVSpeechSynthesisVoice.speechVoices().sorted(by: {$0.language > $1.language})
        selectedVoiceIdentifire  = UserDefaults.standard.string(forKey: "selectedVoiceIdentifire")
    }
    
    func delete(_ leitner:Leitner){
        if let index = leitners.firstIndex(where: {$0 == leitner}){
            leitners.remove(at: index)
        }
        viewContext.delete(leitner)
        saveDB()
    }
    
    func saveDB(){
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func editOrAddLeitner(){
        if selectedLeitner != nil{
            editLeitner()
        }else{
            addLeitner()
        }
    }
    
    func editLeitner(){
        selectedLeitner?.name = leitnerTitle
        selectedLeitner?.backToTopLevel = backToTopLevel
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        showEditOrAddLeitnerAlert.toggle()
    }
    
    func addLeitner() {
        withAnimation {
            
            let maxId = leitners.max(by: {$0.id < $1.id})?.id ?? 0
            let newItem = Leitner(context: viewContext)
            newItem.createDate = Date()
            newItem.name = leitnerTitle
            newItem.id = maxId + 1
            newItem.backToTopLevel = backToTopLevel
            let levels:[Level] = (1...13).map{ levelId in
                let level = Level(context: viewContext)
                level.level = Int16(levelId)
                level.leitner = newItem
                level.daysToRecommend = Int32(levelId) * 2
                return level
            }
            newItem.level?.addingObjects(from: levels)
            leitners.append(newItem)
            saveDB()
            showEditOrAddLeitnerAlert.toggle()
            clear()
        }
    }
    
    func clear(){
        leitnerTitle = ""
        backToTopLevel = false
        selectedLeitner = nil
    }
    
    func exportDB(){
        
        let backupStoreOptions: [AnyHashable: Any] = [
            
            
            NSReadOnlyPersistentStoreOption: true,
            // Disable write-ahead logging. Benefit: the entire store will be
            // contained in a single file. No need to handle -wal/-shm files.
            // https://developer.apple.com/library/content/qa/qa1809/_index.html
            NSSQLitePragmasOption: ["journal_mode": "DELETE"],
            // Minimize file size
            NSSQLiteManualVacuumOption: true,
            ]
        
        
        guard let sourcePersistentStore = PersistenceController.shared.container.persistentStoreCoordinator.persistentStores.first else {return}
        
        let managedObjectModel = PersistenceController.shared.container.managedObjectModel
        
        let backupPersistentContainer = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let intermediateStoreOptions = (sourcePersistentStore.options ?? [:]).merging([NSReadOnlyPersistentStoreOption: true],uniquingKeysWith: { $1 })
        
        do{           
            let newPersistentStore = try backupPersistentContainer.addPersistentStore(
                ofType: sourcePersistentStore.type,
                configurationName: sourcePersistentStore.configurationName,
                at: sourcePersistentStore.url,
                options: intermediateStoreOptions
            )
            
            let exportFile = makeFilename(sourcePersistentStore)
            let backupFile = try TemporaryFile(creatingTempDirectoryForFilename: exportFile)
            self.backupFile = backupFile
            try backupPersistentContainer.migratePersistentStore(newPersistentStore, to: backupFile.fileURL, options: backupStoreOptions, withType: NSSQLiteStoreType)
            print("file exported to\(backupFile.fileURL)")
            showBackupFileShareSheet.toggle()
        }catch{
            print("failed to export: Error \(error.localizedDescription)")
        }
    }
    
    func importDB(){
        
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
    
    func setSelectedVoice(_ voice: AVSpeechSynthesisVoice){
        selectedVoiceIdentifire = voice.identifier
        UserDefaults.standard.set(selectedVoiceIdentifire, forKey: "selectedVoiceIdentifire")
    }

}
