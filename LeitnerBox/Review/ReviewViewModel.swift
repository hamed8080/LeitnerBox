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
    
    @AppStorage("selectedVoiceIdentifire")
    var selectedVoiceIdentifire = ""
    
    @AppStorage("pronounceDetailAnswer")
    private var pronounceDetailAnswer = false
    
    @Published
    var tags:[Tag] = []
    
    init(level:Level, isPreview:Bool = false){
        self.level = level
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.level == %d && level.leitner.id == %d", level.level, level.leitner?.id ?? 0)
        do {
            self.questions = try viewContext.fetch(req).filter({$0.isReviewable}).shuffled()
            totalCount = questions.count
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
        
        preapareNext(questions.first)
        loadTags()
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
    
    func pass(){
        isShowingAnswer = false
        passCount += 1
        selectedQuestion?.passTime = Date()
        if selectedQuestion?.level?.level == 13{
            selectedQuestion?.completed = true
        }else{
            selectedQuestion?.level = selectedQuestion?.upperLevel
        }
        
        saveDB()
        removeFromList()
        if !hasNext{
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }
    
    func fail(){
        isShowingAnswer = false
        if level.leitner?.backToTopLevel == true{
            selectedQuestion?.level = selectedQuestion?.firstLevel
            saveDB()
        }
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
        synthesizer.stopSpeaking(at: .immediate)
        let utterance                = AVSpeechUtterance(string: "\(question.question ?? "") \( pronounceDetailAnswer ? (question.detailDescription ?? "") : "")")
        if !selectedVoiceIdentifire.isEmpty{
            utterance.voice          = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifire)
        }
        utterance.rate               = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier    = 1
        utterance.postUtteranceDelay = 0
        synthesizer.speak(utterance)
    }
    
    func toggleAnswer(){
        isShowingAnswer.toggle()
    }
    
    func preapareNext(_ question:Question?){
        selectedQuestion = question
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
        guard let selectedQuestion = selectedQuestion else {return}
        tag.addToQuestion(selectedQuestion)
        saveDB()
    }
    
    func removeTagForQuestion(_ tag:Tag){
        withAnimation {
            guard let selectedQuestion = selectedQuestion else {return}
            tag.addToQuestion(selectedQuestion)
            saveDB()
        }
    }
    
}
