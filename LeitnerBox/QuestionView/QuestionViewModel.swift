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
    var viewContext:NSManagedObjectContext = PersistenceController.shared.container.viewContext
    
    @Published
    var level:Level
    
    var editQuestion:Question? = nil
    
    @Published
    var isManual = true
    
    @Published
    var questions:[Question] = []
    
    @Published
    var answer:String = ""
    
    @Published
    var descriptionDetail:String = ""
    
    @Published
    var question:String = ""
    
    init(level:Level, editQuestion:Question? = nil){
        self.editQuestion = editQuestion
        if let editQuestion = editQuestion {
            question          = editQuestion.question ?? ""
            answer            = editQuestion.answer ?? ""
            descriptionDetail = editQuestion.detailDescription ?? ""
        }
        self.level        = level
    }
    
    func saveEdit(){
        do{
            editQuestion?.question = self.question
            editQuestion?.answer = self.answer
            editQuestion?.detailDescription = self.descriptionDetail
            try viewContext.save()
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
    }
    
    func insert() {
        withAnimation {
            let question               = Question(context : viewContext)
            question.question          = self.question
            question.answer            = answer
            question.detailDescription = self.descriptionDetail
            question.level             = level
            question.createTime        = Date()
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { questions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func save(){
        if editQuestion != nil{
            saveEdit()
        }else{
            insert()
        }
    }
    
    func clear(){
        editQuestion = nil
        answer = ""
        question = ""
    }
}
