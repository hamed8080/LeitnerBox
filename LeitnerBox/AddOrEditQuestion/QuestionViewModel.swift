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
    var editQuestion: Question? = nil

    @Published
    var isInEditMode: Bool = false
    
    init(viewContext:NSManagedObjectContext, level:Level, editQuestion:Question? = nil){
        self.viewContext = viewContext
        self.level = level
        self.setEditQuestionProperties(editQuestion: editQuestion)
    }
    
    func saveEdit(){
        editQuestion?.question = self.questionString
        editQuestion?.answer = self.answer
        editQuestion?.detailDescription = self.descriptionDetail
        editQuestion?.completed         = isCompleted
        
        if editQuestion?.favorite == false && isFavorite {
            editQuestion?.favoriteDate = Date()
        }
        editQuestion?.favorite          = isFavorite
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func insert() {
        withAnimation {
            let question               = Question(context: viewContext)
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
        isInEditMode = false
    }

    func setEditQuestionProperties(editQuestion: Question?){
        if let editQuestion = editQuestion {
            self.isInEditMode = true
            self.editQuestion = editQuestion
            questionString    = editQuestion.question ?? ""
            answer            = editQuestion.answer ?? ""
            isCompleted       = editQuestion.completed
            descriptionDetail = editQuestion.detailDescription ?? ""
            isFavorite        = editQuestion.favorite
        }
    }
}
