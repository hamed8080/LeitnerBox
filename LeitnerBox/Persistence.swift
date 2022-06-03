//
//  Persistence.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import CoreData
import SwiftUI

class PersistenceController:ObservableObject {
    
    static var shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<10 {
            let newItem = Leitner(context: viewContext)
            newItem.createDate = Date()
            newItem.name = "English"
            newItem.id = Int64(index)
            
            newItem.level?.addingObjects(from: (1...13).map{ levelId in
                let level = Level(context: viewContext)
                level.level = Int16(levelId)
                level.leitner = newItem
                level.daysToRecommend = 8
                level.questions?.addingObjects(from: (1...500).map{ questionId in
                    let question = Question(context: viewContext)
                    question.question = "Quesiton \(questionId)"
                    question.answer = "Answer with long text to test how it looks like on small screen we want to sure that the text is perfectly fit on the screen on smart phones and computers even with huge large screen \(questionId)"
                    question.level = level
                    question.passTime = Date().advanced(by: -(24 * 360))
                    question.createTime = Date()
                    return question
                })
                return level
            })
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    var container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        UIColorValueTransformer.register()
        container = NSPersistentCloudKitContainer(name: "LeitnerBox")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    
    func replaceDBIfExistFromShareExtension(){
       let appSuppportFile = moveAppGroupFileToAppSupportFolder()
        if let appSuppportFile = appSuppportFile {
            replaceDatabase(appSuppportFile: appSuppportFile)
        }
    }
    
    func moveAppGroupFileToAppSupportFolder()->URL?{
        let fm = FileManager.default
        guard let appGroupDBFolder = fm.appGroupDBFolder else{return nil}
        if let contents = try? fm.contentsOfDirectory(atPath: appGroupDBFolder.path).filter({$0.contains(".sqlite")}), contents.count > 0 {

            let appSupportDirectory = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            let appGroupFile = appGroupDBFolder.appendingPathComponent(contents.first!)
            let appSuppportFile = appSupportDirectory!.appendingPathComponent(contents.first!)
            do{
                if fm.fileExists(atPath: appSuppportFile.path){
                    try fm.removeItem(at: appSuppportFile)//to first delete old file and again replace with new one
                }
                try fm.moveItem(atPath: appGroupFile.path , toPath:  appSuppportFile.path)
                return appSuppportFile
            }catch{
                print("Error to move appgroup file to app support folder\(error.localizedDescription)")
                return nil
            }
        }else{
            return nil
        }
    }
    
    func replaceDatabase(appSuppportFile:URL){
        do{
            let persistentCordinator = PersistenceController.shared.container.persistentStoreCoordinator
            guard let oldStore = persistentCordinator.persistentStores.first , let oldStoreUrl = oldStore.url else{return}
            try persistentCordinator.replacePersistentStore(at: oldStoreUrl, withPersistentStoreFrom: appSuppportFile, type: .sqlite)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
                self.objectWillChange.send()
            })
            container.viewContext.automaticallyMergesChangesFromParent = true
        }catch{
            print("error in restoring back up file\(error.localizedDescription)")
        }
    }
    
    func dropDatabase(_ info:DropInfo){
        info.itemProviders(for: [.fileURL, .data]).forEach { item in
            item.loadItem(forTypeIdentifier: item.registeredTypeIdentifiers.first!,options: nil){ data,error in
                do {
                    if let url = data as? URL,
                       let newFileLocation = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(url.lastPathComponent){
                        if FileManager.default.fileExists(atPath: newFileLocation.path){
                            try FileManager.default.removeItem(atPath: newFileLocation.path)
                        }
                        let fileData = try Data(contentsOf: url)
                        try fileData.write(to: newFileLocation)
                        PersistenceController.shared.replaceDatabase(appSuppportFile: newFileLocation)
                    }
                }catch{
                    print("error happend\(error.localizedDescription)")
                }
            }
        }
    }
}
