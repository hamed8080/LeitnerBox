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
    
    init(level:Level, editQuestion:Question? = nil){
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
        do{
            editQuestion?.question = self.question
            editQuestion?.answer = self.answer
            editQuestion?.detailDescription = self.descriptionDetail
            editQuestion?.completed         = isCompleted
            addedTags.forEach { tag in
                if let editQuestion = editQuestion {
                    tag.addToQuestion(editQuestion)
                }
            }
            try viewContext.save()
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
    }
    
    func insert() -> Question{
        withAnimation {
            let question               = Question(context : viewContext)
            question.question          = self.question
            question.answer            = answer
            question.detailDescription = self.descriptionDetail
            question.level             = level
            question.completed         = isCompleted
            
            if question.completed {
                if let lastLevel = (level.leitner?.level?.allObjects as? [Level])?.first(where: {$0.level == 13}) {
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
            do {
                try viewContext.save()
                return question
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
    
    func save()->QuestionStateChanged{
        if let editQuestion = editQuestion{
            saveEdit()
            return .EDITED(editQuestion)
        }else{
            let question = insert()
            return .INSERTED(question)
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
        do {
            self.tags = try viewContext.fetch(req)
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
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

enum QuestionStateChanged{
    case EDITED(Question)
    case DELTED(Question)
    case INSERTED(Question)
}
