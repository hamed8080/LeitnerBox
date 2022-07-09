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
    var viewContext:NSManagedObjectContext

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

    init(viewContext:NSManagedObjectContext, leitner:Leitner){
        self.viewContext = viewContext
        self.leitner = leitner
        load()
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach(viewContext.delete)
            tags.remove(atOffsets: offsets)
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
    
    func load(){
        let predicate = NSPredicate(format: "leitner.id == %d", leitner.id)
        let req = Tag.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        self.tags = (try? viewContext.fetch(req)) ?? []
    }
    
    func addToTag(_ tag:Tag, _ question:Question){
        withAnimation {
            if let tag = tags.first(where: {$0.objectID == tag.objectID}){
                tag.addToQuestion(question)
                PersistenceController.saveDB(viewContext: viewContext)
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
        PersistenceController.saveDB(viewContext: viewContext)
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
            PersistenceController.saveDB(viewContext: viewContext)
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
