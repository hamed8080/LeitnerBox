//
//  ReviewViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

class ReviewViewModel:ObservableObject{
    
    @Published
    var viewContext:NSManagedObjectContext

    @Published
    var questions: [Question] = []
    
    @Published
    var showAddQuestionView = false
    
    @Published
    var showEditQuestionView = false
    
    @Published
    var showSearchView = false
    
    @Published
    var showDelete = false
    
    @Published
    var level:Level
    
    @Published
    var failedCount = 0
    
    @Published
    var passCount = 0
    
    var synthesizer = AVSpeechSynthesizer()
    
    @Published
    var selectedQuestion:Question? = nil
    
    @Published
    var isShowingAnswer = false
    
    @Published
    var totalCount = 0
    
    @Published
    var isFinished = false
    
    init(level:Level, isPreview:Bool = false){
        self.level = level
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.level == %d && level.leitner.id == %d", level.level, level.leitner?.id ?? 0)
        do {
            self.questions = try viewContext.fetch(req).filter({$0.isReviewable})
            totalCount = questions.count
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
        
        preapareNext(questions.first)
    }
    
    func saveDB(){
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    func deleteQuestion(){
        if let selectedQuestion = selectedQuestion {
            viewContext.delete(selectedQuestion)
            saveDB()
        }
        removeFromList()
        if !hasNext{
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }
    
    func toggleFavorite(){
        selectedQuestion?.favorite.toggle()
        saveDB()
        objectWillChange.send()
    }
    
    func editQuestion(){
        showEditQuestionView.toggle()
    }
    
    func pass(){
        passCount += 1
        removeFromList()
        if !hasNext{
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }
    
    func fail(){
        failedCount += 1
        removeFromList()
        if !hasNext{
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }
    
    func removeFromList(){
        if let selectedQuestion = selectedQuestion {
            questions.removeAll(where: { $0 == selectedQuestion})
        }
    }
    
    func showDeleteDialog(){
        showDelete.toggle()
    }
    
    var hasNext:Bool{
        questions.count > 0
    }
    
    func pronounce(){
        guard let question = selectedQuestion else { return }
        let utterance                = AVSpeechUtterance(string          : question.question ?? "")
        utterance.voice              = AVSpeechSynthesisVoice(language : "en-GB")
        utterance.rate               = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier    = 1
        utterance.postUtteranceDelay = 0
        synthesizer.speak(utterance)
    }
    
    func toggleAnswer(){
        
    }
    
    func preapareNext(_ question:Question?){
        selectedQuestion = question
    }
}
