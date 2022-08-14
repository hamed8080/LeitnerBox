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
import NaturalLanguage

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
    
    init(viewContext:NSManagedObjectContext, level:Level){
        self.level = level
        self.viewContext = viewContext
        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.level == %d && level.leitner.id == %d", level.level, level.leitner?.id ?? 0)
        self.questions = ((try? viewContext.fetch(req)) ?? []).filter({$0.isReviewable}).shuffled()
        totalCount = questions.count
        preapareNext(questions.first)
        loadTags()
    }
    
    func deleteQuestion(){
        if let selectedQuestion {
            viewContext.delete(selectedQuestion)
            PersistenceController.saveDB(viewContext: viewContext)
            toggleDeleteDialog()
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
        PersistenceController.saveDB(viewContext: viewContext)
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

        let statistic = Statistic(context: viewContext)
        statistic.question = selectedQuestion
        statistic.actionDate = Date()
        statistic.isPassed = true
        selectedQuestion?.statistics?.adding(statistic)

        PersistenceController.saveDB(viewContext: viewContext)
        removeFromList()
        if !hasNext{
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }
    
    func fail(){
        isShowingAnswer = false
        
        let statistic = Statistic(context: viewContext)
        statistic.question = selectedQuestion
        statistic.actionDate = Date()
        statistic.isPassed = false
        selectedQuestion?.statistics?.adding(statistic)
        
        if level.leitner?.backToTopLevel == true{
            selectedQuestion?.level = selectedQuestion?.firstLevel
        }
        PersistenceController.saveDB(viewContext: viewContext)
        failedCount += 1
        removeFromList()
        if !hasNext{
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }
    
    func removeFromList(){
        if let selectedQuestion {
            questions.removeAll(where: { $0 == selectedQuestion})
        }
    }
    
    func toggleDeleteDialog(){
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
        self.tags = (try? viewContext.fetch(req)) ?? []
    }
    
    func addTagToQuestion(_ tag:Tag){
        guard let selectedQuestion = selectedQuestion else {return}
        tag.addToQuestion(selectedQuestion)
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func removeTagForQuestion(_ tag:Tag){
        withAnimation {
            guard let selectedQuestion = selectedQuestion else {return}
            tag.removeFromQuestion(selectedQuestion)
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
    
    var partOfspeech:String?{
        let text = String((selectedQuestion?.question ?? "").split(separator: "\n").first!)
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        var tags:[String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                tags.append("\(tag.rawValue)")
            }
            return true
        }
        return tags.joined(separator: ", ")
    }
    
}
