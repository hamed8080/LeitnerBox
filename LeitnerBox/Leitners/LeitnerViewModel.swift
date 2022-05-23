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
    
    init(isPreview:Bool = false){
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        let req = Leitner.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Leitner.createDate, ascending: true)]
        do {
            self.leitners = try viewContext.fetch(req)
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
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
}
