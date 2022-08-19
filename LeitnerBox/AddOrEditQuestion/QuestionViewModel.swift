//
//  QuestionViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData

class QuestionViewModel:ObservableObject{
    
    @Published
    var viewContext:NSManagedObjectContext
    
    @Published
    var level:Level

    @Published
    var editQuestion:Question? = nil
    
    @Published
    var isManual = true
    
    @Published
    var isCompleted = false
    
    @Published
    var questions:[Question] = []
    
    @Published
    var answer:String = ""
    
    @Published
    var descriptionDetail:String = ""
    
    @Published
    var question:String = ""
    
    @Published
    var tags:[Tag] = []
    
    @Published
    var addedTags:[Tag] = []
    
    @Published
    var isFavorite:Bool = false
    
    init(viewContext:NSManagedObjectContext, level:Level, editQuestion:Question? = nil){
        self.viewContext = viewContext
        self.editQuestion = editQuestion
        if let editQuestion = editQuestion {
            question          = editQuestion.question ?? ""
            answer            = editQuestion.answer ?? ""
            isCompleted       = editQuestion.completed
            descriptionDetail = editQuestion.detailDescription ?? ""
            isFavorite        = editQuestion.favorite
        }
        self.level        = level
        
        loadTags()
    }
    
    func saveEdit(){
        editQuestion?.question = self.question
        editQuestion?.answer = self.answer
        editQuestion?.detailDescription = self.descriptionDetail
        editQuestion?.completed         = isCompleted
        
        if editQuestion?.favorite == false && isFavorite {
            editQuestion?.favoriteDate = Date()
        }
        editQuestion?.favorite          = isFavorite
        addedTags.forEach { tag in
            if let editQuestion = editQuestion {
                tag.addToQuestion(editQuestion)
            }
        }
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func insert() {
        withAnimation {
            let question               = Question(context : viewContext)
            question.question          = self.question
            question.answer            = answer
            question.detailDescription = self.descriptionDetail
            question.level             = level
            question.completed         = isCompleted
            
            if question.completed {
                if let lastLevel = level.leitner?.levels.first(where: {$0.level == 13}) {
                    question.level     = lastLevel
                    question.passTime  = Date()
                    question.completed = true
                }
            }
            
            question.createTime        = Date()
            question.favorite          = isFavorite
            if question.favorite {
                question.favoriteDate = Date()
            }
            addedTags.forEach { tag in
                tag.addToQuestion(question)
            }
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
    
    func save() {
        if editQuestion != nil {
            saveEdit()
        }else{
            insert()
        }
    }
    
    func clear(){
        editQuestion = nil
        answer = ""
        question = ""
        addedTags = []
        isCompleted = false
        isManual = true
        descriptionDetail = ""
    }
    
    func loadTags(){
        guard let leitnerId = level.leitner?.id else{return}
        let predicate = NSPredicate(format: "leitner.id == %d", leitnerId)
        let req = Tag.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        self.tags = (try? viewContext.fetch(req)) ?? []
    }
    
    
    func addTagToQuestion(_ tag:Tag){
        addedTags.append(tag)
    }
    
    func removeTagForQuestio(_ tag:Tag){
        withAnimation {
            addedTags.removeAll(where: {$0 == tag})
            if let editQuestion = editQuestion {
                tag.removeFromQuestion(editQuestion)
            }
        }
    }
}
