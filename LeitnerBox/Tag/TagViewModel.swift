//
//  TagViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData

class TagViewModel:ObservableObject{
    
    @Published
    var viewContext:NSManagedObjectContext = PersistenceController.shared.container.viewContext

    @Published
    var tags:[Tag] = []
    
    @Published
    var leitner:Leitner
    
    @Published
    var showAddOrEditTagDialog:Bool = false
    
    @Published
    var selectedTag:Tag? = nil
    
    @Published
    var tagName:String = ""
    
    @Published
    var colorPickerColor:Color = .gray

    init(leitner:Leitner, isPreview:Bool = false ){
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        self.leitner = leitner
        load()
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach(viewContext.delete)
            tags.remove(atOffsets: offsets)
            saveDB()
        }
    }
    
    func delete(_ question:Question){
        viewContext.delete(question)
        if let index = tags.firstIndex(where: {$0 == question}){
            tags.remove(at: index)
        }
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
    
    func load(){
        let predicate = NSPredicate(format: "leitner.id == %d", leitner.id)
        let req = Tag.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        do {
            self.tags = try viewContext.fetch(req)
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
    }
    
    func addToTag(_ tag:Tag, _ question:Question){
        withAnimation {
            if let tag = tags.first(where: {$0.objectID == tag.objectID}){
                tag.addToQuestion(question)
                saveDB()
            }
        }
    }
    
    func editOrAddTag(){
        if selectedTag != nil{
            editTag()
        }else{
            addTag()
        }
    }
    
    func editTag(){
        selectedTag?.name = tagName
        if let cgColor = colorPickerColor.cgColor{
            selectedTag?.color = UIColor(cgColor: cgColor)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        showAddOrEditTagDialog.toggle()
    }
    
    func addTag() {
        withAnimation {
            let newItem = Tag(context: viewContext)
            newItem.leitner = leitner
            newItem.name = tagName
            
            if let cgColor = colorPickerColor.cgColor{
                newItem.color = UIColor(cgColor: cgColor)
            }
            tags.append(newItem)
            saveDB()
            showAddOrEditTagDialog.toggle()
            clear()
        }
    }
    
    func clear(){
        colorPickerColor = .gray
        tagName = ""
        selectedTag = nil
    }
}
