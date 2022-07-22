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
    var viewContext:NSManagedObjectContext
    
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
        if searchWord.isEmpty || searchWord == "#"{
            return []
        }
        let tagName = searchWord.replacingOccurrences(of: "#", with: "")
        if searchWord.contains("#"), tagName.isEmpty == false{
            return allQuestions.filter({
                $0.tagsArray?.contains(where: {$0.name?.lowercased().contains(tagName.lowercased()) ?? false}) ?? false
            })
        }
        return allQuestions.filter{
            $0.question?.lowercased().contains(searchWord.lowercased()) ?? false ||
            $0.answer?.lowercased().contains(searchWord.lowercased()) ?? false ||
            $0.detailDescription?.lowercased().contains( searchWord.lowercased()) ?? false
        }
    }
    
    init(viewContext:NSManagedObjectContext, leitner:Leitner){
        self.viewContext = viewContext
        self.leitner = leitner
        load()
    }
    
    func saveDaysToRecommned(){
        selectedLevel?.daysToRecommend = Int32(daysToRecommend)
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func load(){
        let predicate = NSPredicate(format: "leitner.id == %d", self.leitner.id)
        let req = Level.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Level.level, ascending: true)]
        req.predicate = predicate
        self.levels = (try? viewContext.fetch(req)) ?? []
        allQuestions.removeAll()
        levels.forEach { level in
            level.allQuestions.forEach({ question in
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
