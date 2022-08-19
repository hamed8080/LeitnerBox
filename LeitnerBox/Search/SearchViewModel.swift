//
//  SearchViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation
import MediaPlayer

class SearchViewModel:ObservableObject{
   
    @AppStorage("pronounceDetailAnswer")
    private var pronounceDetailAnswer = false
    
    @Published
    var viewContext:NSManagedObjectContext

    @Published
    var searchText:String = ""
    
    @Published
    var showLeitnersListDialog = false
    
    @Published
    var leitner:Leitner

    @Published
    var editQuestion:Question? = nil
    
    @Published
    var selectedSort:SearchSort = .LEVEL

    private (set) var sorted:[Question] = []
    
    var synthesizer = AVSpeechSynthesizer()
    
    var speechDelegate:SpeechDelegate
    
    @AppStorage("selectedVoiceIdentifire")
    var selectedVoiceIdentifire = ""
    
    @Published
    var isSpeaking = false
    
    var commandCenter:MPRemoteCommandCenter? = nil

    init(viewContext:NSManagedObjectContext, leitner:Leitner){
        self.viewContext = viewContext
        self.speechDelegate = SpeechDelegate()
        synthesizer.delegate = speechDelegate
        self.leitner = leitner
        sort(.DATE)
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { sorted[$0] }.forEach(viewContext.delete)
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
    
    func delete(_ question:Question){
        viewContext.delete(question)
        sorted.removeAll(where: {$0 == question})
        PersistenceController.saveDB(viewContext: viewContext)
        objectWillChange.send() // notify to redrawn filtred items and delete selected question
    }

    func addSynonym(question: Question, synonymQuestion:Question){
        if let firstSynonym = question.synonymsArray?.first{
            firstSynonym.addToQuestion(synonymQuestion)
        }else{
            let synonym = Synonym(context: viewContext)
            synonym.addToQuestion(question)
        }
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func sort(_ sort:SearchSort){
        selectedSort = sort
        let all = leitner.allQuestions
        switch sort {
        case .LEVEL:
            sorted = all.sorted(by: {
                ($0.level?.level ?? 0, $1.createTime?.timeIntervalSince1970 ?? -1) < ($1.level?.level ?? 0, $0.createTime?.timeIntervalSince1970 ?? -1)
            })
        case .COMPLETED:
            sorted = all.sorted(by: { first,second in
                (first.completed ? 1: 0,first.passTime?.timeIntervalSince1970 ?? -1) > (second.completed ? 1: 0,second.passTime?.timeIntervalSince1970 ?? -1)
            })
        case .ALPHABET:
            sorted = all.sorted(by: {
                ($0.question?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") < ($1.question?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            })
        case .FAVORITE:
            sorted = all.sorted(by: {
                ($0.favorite ? 1 : 0, $0.favoriteDate?.timeIntervalSince1970 ?? -1 ) > ($1.favorite ? 1 : 0, $1.favoriteDate?.timeIntervalSince1970 ?? -1)
            })
        case .DATE:
            sorted = all.sorted(by: {
                ($0.createTime?.timeIntervalSince1970 ?? -1) > ($1.createTime?.timeIntervalSince1970 ?? -1)
            })
        case .PASSED_TIME:
            sorted = all.sorted(by: {
                ($0.passTime?.timeIntervalSince1970 ?? -1) > ($1.passTime?.timeIntervalSince1970 ?? -1)
            })
        case .NO_TAGS:
            sorted = all.sorted(by: {
                ($0.tagsArray?.count ?? 0) < ($1.tagsArray?.count ?? 0)
            })
        case .TAGS:
            sorted = all.sorted(by: {
                ($0.tagsArray?.count ?? 0) > ($1.tagsArray?.count ?? 0)
            })
        }
    }
    
    func toggleCompleted(_ question:Question){
        question.completed.toggle()
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func toggleFavorite(_ question:Question){
        question.favorite.toggle()
        PersistenceController.saveDB(viewContext: viewContext)
    }
    
    func resetToFirstLevel(_ question:Question){
        if let firstLevel = leitner.levels.first(where: {$0.level == 1}){
            question.level = firstLevel
            question.passTime  = nil
            question.completed = false
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
    
    func pronounceOnce(_ question:Question){
        pronounce(question)
        isSpeaking = false
    }
    
    func pronounce(_ question:Question){
        isSpeaking                   = true
        let pronounceString          = "\(question.question ?? "") \(pronounceDetailAnswer ? (question.detailDescription ?? "") : "")"
        let utterance                = AVSpeechUtterance(string : pronounceString)
        utterance.voice              = AVSpeechSynthesisVoice(language : "en-GB")
        utterance.rate               = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier    = 1
        if !selectedVoiceIdentifire.isEmpty{
            utterance.voice              = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifire)
        }
        utterance.postUtteranceDelay = 0
        synthesizer.speak(utterance)
    }
    
    var timer:Timer? = nil
    var lastPlayedQuestion:Question? = nil
    func playReview(){
        isSpeaking                   = true
        if speechDelegate.viewModel == nil{
            speechDelegate.viewModel = self
        }
        
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }else if lastPlayedQuestion != nil{
            //this play because of pause method stop timer and at the result next not called anymore
            playNext()
        }else if lastPlayedQuestion == nil, let firstQuestion = sorted.first{
            pronounce(firstQuestion)
            lastPlayedQuestion = firstQuestion
        }else if let firstQuestion = sorted.first{
            pronounce(firstQuestion)
            lastPlayedQuestion = firstQuestion
        }
    }
    
    func playNext(){
        if let lastPlayedQuestion = lastPlayedQuestion, let index = sorted.firstIndex(of: lastPlayedQuestion), sorted.indices.contains(index + 1){
            let nextQuestion = sorted[index + 1]
            pronounce(nextQuestion)
            self.lastPlayedQuestion = nextQuestion
        }
    }
    
    func playNextImmediately(){
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = speechDelegate
        playNext()
    }
    
    func hasNext()->Bool{
        if let lastPlayedQuestion = lastPlayedQuestion, let index = sorted.firstIndex(of: lastPlayedQuestion), sorted.indices.contains(index + 1){
            return true
        }else{
            return false
        }
    }
    
    func pauseReview(){
        isSpeaking = false
        speechDelegate.task?.cancel()
        if synthesizer.isSpeaking{
            synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    func stopReview(){
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        speechDelegate.task?.cancel()
        self.lastPlayedQuestion = nil
    }
    
    func finished(){
        isSpeaking = false
        lastPlayedQuestion = nil
    }
    
    var reviewdCount:Int{
        if let lastPlayedQuestion = lastPlayedQuestion , let index = sorted.firstIndex(of: lastPlayedQuestion){
            return index + 1
        }else{
            return 0
        }
    }

    func moveQuestionTo(_ question: Question, leitner:Leitner){
        question.level = leitner.firstLevel
        question.passTime  = nil
        question.completed = false
        PersistenceController.saveDB(viewContext: viewContext)
        sorted.removeAll(where: { $0 == question })
        objectWillChange.send()
    }
    
    func viewDidAppear(){
        commandCenter = MPRemoteCommandCenter.shared()
        commandCenter?.playCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            self.togglePlayPauseReview()
            return .success
        }
        commandCenter?.pauseCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            self.togglePlayPauseReview()
            return .success
        }
    }
    
    func togglePlayPauseReview(){
        if isSpeaking{
            pauseReview()
        }else{
            playReview()
        }
    }
    
    var filtered:[Question]{
        if searchText.isEmpty || searchText == "#"{
            return sorted
        }
        let tagName = searchText.replacingOccurrences(of: "#", with: "")
        if searchText.contains("#"), tagName.isEmpty == false{
            return sorted.filter({
                $0.tagsArray?.contains(where: {$0.name?.lowercased().contains(tagName.lowercased()) ?? false}) ?? false
            })
        }else{
            return sorted.filter({
                $0.question?.lowercased().contains( searchText.lowercased()) ?? false ||
                $0.answer?.lowercased().contains( searchText.lowercased()) ?? false ||
                $0.detailDescription?.lowercased().contains( searchText.lowercased()) ?? false
            })
        }
    }
    
    func complete(_ question:Question){
        if let lastLevel = leitner.levels.first(where: {$0.level == 13}) {
            question.level     = lastLevel
            question.passTime  = Date()
            question.completed = true
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }
}

class SpeechDelegate:NSObject, AVSpeechSynthesizerDelegate{

    var viewModel:SearchViewModel? = nil
    var task:Task<Void, Error>? = nil

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if viewModel?.hasNext() == true{
            timerTask()
        }else{
            viewModel?.finished()
        }
    }

    func timerTask(){
        task = Task {
            guard !Task.isCancelled else {return}
            try await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                self.viewModel?.playNext()
            }
        }
    }
}


var searchSorts:[SortModel] = [
    .init(iconName:"textformat.abc", title:"Alphabet", sortType:.ALPHABET),
    .init(iconName:"arrow.up.arrow.down.square", title:"Level", sortType:.LEVEL),
    .init(iconName:"calendar.badge.clock", title:"Create Date", sortType:.DATE),
    .init(iconName:"calendar.badge.clock", title:"Passed Date", sortType:.PASSED_TIME),
    .init(iconName:"star", title:"Favorite", sortType:.FAVORITE),
    .init(iconName:"flag.2.crossed", title:"Completed", sortType:.COMPLETED),
    .init(iconName:"tag", title:"Tags", sortType:.TAGS),
    .init(iconName:"tag.slash", title:"Without Tags", sortType:.NO_TAGS),
]

struct SortModel:Hashable{
    let iconName:String
    let title:String
    let sortType:SearchSort
}

enum SearchSort{
    
    case LEVEL
    case COMPLETED
    case ALPHABET
    case FAVORITE
    case DATE
    case PASSED_TIME
    case TAGS
    case NO_TAGS
}
