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
    
    static let previewPS = PersistenceController(inMemory: true)
    
    static var previewVC:NSManagedObjectContext{
        return previewPS.container.viewContext
    }
    
    static var preview: PersistenceController = {
        
        let leitners = generateLeitner(5)
        leitners.forEach { leitner in
            generateLevels(leitner: leitner).forEach { level in
              let questions = generateQuestions(5, level)
                generateTags(5,leitner).forEach { tag in
                    questions.forEach { question in
                        tag.addToQuestion(question)
                    }
                }
            }
        }
        do {
            try previewVC.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return previewPS
    }()
    
    static func generateLevels(leitner:Leitner)->[Level]{
        var levels:[Level] = []
        for index in 1..<13 {
            let level = Level(context: previewVC)
            level.level = Int16(index)
            level.leitner = leitner
            level.daysToRecommend = 8
            levels.append(level)
        }
        return levels
    }
    
    static func generateLeitner(_ count:Int)->[Leitner]{
        var leitners:[Leitner] = []
        for index in 0..<count {
            let leitner = Leitner(context: previewVC)
            leitner.createDate = Date()
            leitner.name = "English"
            leitner.id = Int64(index)
            leitners.append(leitner)
        }
        return leitners
    }
    
    static func generateTags(_ count:Int, _ leitner:Leitner)->[Tag]{
        var tags:[Tag] = []
        for index in 0..<count {
            let tag = Tag(context: previewVC)
            tag.name = "Tag \(index)"
            tag.color = UIColor.random()
            tag.leitner = leitner
            tags.append(tag)
        }
        return tags
    }
    
    static func generateQuestions(_ count:Int, _ level:Level)->[Question]{
        var questions:[Question] = []
        for index in 0..<count {
            let question = Question(context: previewVC)
            question.question = "Quesiton \(index)"
            question.answer = "Answer with long text to test how it looks like on small screen we want to sure that the text is perfectly fit on the screen on smart phones and computers even with huge large screen \(index)"
            question.level = level
            question.passTime = level.level == 1 ? nil : Date().advanced(by: -(24 * 360))
            question.createTime = Date()
            
            questions.append(question)
        }
        return questions
    }
    
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
