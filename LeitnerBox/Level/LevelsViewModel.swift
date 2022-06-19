//
//  LevelsViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

class LevelsViewModel:ObservableObject{
   
    @Published
    var viewContext:NSManagedObjectContext = PersistenceController.shared.container.viewContext
    
    @Published
    var leitner:Leitner
    
    @Published
    var searchWord:String = ""
    
    @Published
    var levels: [Level] = []
    
    @Published
    var allQuestions:[Question] = []
    
    @Published
    var showDaysAfterDialog = false
    
    @Published
    var selectedLevel:Level? = nil
    
    @Published
    var daysToRecommend = 0
    
    var filtered:[Question] {
        if searchWord.isEmpty{
            return []
        }
        if searchWord.contains("#"){
            let tagName = searchWord.replacingOccurrences(of: "#", with: "")
            if tagName.isEmpty == false{
                return allQuestions.filter({
                    $0.tagsArray?.contains(where: {$0.name?.lowercased().contains(tagName.lowercased()) ?? false}) ?? false
                })
            }else{
                return allQuestions
            }
        }
        return allQuestions.filter{
            searchWord.isEmpty ||
            $0.question?.lowercased().contains(searchWord.lowercased()) ?? false ||
            $0.answer?.lowercased().contains(searchWord.lowercased()) ?? false ||
            $0.detailDescription?.lowercased().contains( searchWord.lowercased()) ?? false
        }
    }
    
    init(leitner:Leitner, isPreview:Bool = false ){
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        self.leitner = leitner
        load()
    }
    
    func saveDaysToRecommned(){
        selectedLevel?.daysToRecommend = Int32(daysToRecommend)
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
        let predicate = NSPredicate(format: "leitner.id == %d", self.leitner.id)
        let req = Level.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Level.level, ascending: true)]
        req.predicate = predicate
        do {
            self.levels = try viewContext.fetch(req)
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
        
        allQuestions.removeAll()
        levels.forEach { level in
            (level.questions?.allObjects as? [Question])?.forEach({ question in
                allQuestions.append(question)
            })
        }
    }
    
    func questionStateChanged(state:QuestionStateChanged){
        switch state {
        case .EDITED(let question):
            questionEdited(question)
        case .DELTED(let question):
            questionDeleted(question)
        case .INSERTED(let question):
            questionAdded(question)
        }
    }
    
    func questionDeleted(_ question:Question){
        withAnimation {
            allQuestions.removeAll(where: {$0 == question})
        }
    }
    
    func questionAdded(_ question:Question){
        allQuestions.append(question)
    }
    
    func questionEdited(_ question:Question){
        allQuestions.removeAll(where: {$0 == question})
        allQuestions.append(question)
    }
}
