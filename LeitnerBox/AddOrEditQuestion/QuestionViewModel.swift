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
    var questionString:String = ""
    
    @Published
    var isFavorite:Bool = false

    @Published
    var question: Question

    @Published
    var isInEditMode: Bool
    
    init(viewContext:NSManagedObjectContext, level:Level, editQuestion:Question? = nil){
        self.viewContext = viewContext
        self.isInEditMode = editQuestion != nil
        let insertQuestion = Question(context: viewContext)
        insertQuestion.level = level
        self.question = editQuestion ?? insertQuestion
        if let editQuestion = editQuestion {
            questionString    = editQuestion.question ?? ""
            answer            = editQuestion.answer ?? ""
            isCompleted       = editQuestion.completed
            descriptionDetail = editQuestion.detailDescription ?? ""
            isFavorite        = editQuestion.favorite
        }
        self.level        = level
    }
    
    func saveEdit(){
        question.question = self.questionString
        question.answer = self.answer
        question.detailDescription = self.descriptionDetail
        question.completed         = isCompleted
        
        if question.favorite == false && isFavorite {
            question.favoriteDate = Date()
        }
        question.favorite          = isFavorite
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func insert() {
        withAnimation {
            question.question          = self.questionString
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
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
    
    func save() {
        if isInEditMode {
            saveEdit()
        }else{
            insert()
        }
    }
    
    func clear(){
        answer = ""
        questionString = ""
        isCompleted = false
        isManual = true
        descriptionDetail = ""
    }
}
