//
// SearchViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import Combine
import CoreData
import Foundation
import MediaPlayer
import SwiftUI

enum ReviewStatus {
    case isPlaying
    case isPaused
    case unInitialized
}

class SearchViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @AppStorage("pronounceDetailAnswer") private var pronounceDetailAnswer = false
    @Published var viewContext: NSManagedObjectContextProtocol
    @Published var searchText: String = ""
    @Published var showLeitnersListDialog = false
    @Published var leitner: Leitner
    @Published var editQuestion: Question?
    @Published var selectedSort: SearchSort = .date
    @AppStorage("selectedVoiceIdentifire") var selectedVoiceIdentifire = ""
    @Published var reviewStatus: ReviewStatus = .unInitialized
    private(set) var questions: [Question] = []
    private(set) var searchedQuestions: [Question] = []
    var synthesizer: AVSpeechSynthesizerProtocol
    var commandCenter: MPRemoteCommandCenter?
    private var voiceSpeech: AVSpeechSynthesisVoiceProtocol
    var task: Task<Void, Error>?
    var sortedTags: [Tag] { leitner.tagsArray.sorted(by: { $0.name.isLessThan($1.name) }) }
    private(set) var cancellableSet: Set<AnyCancellable> = []
    var count = 20
    private var offset = 0
    var selectedTag: Tag?

    init(viewContext: NSManagedObjectContextProtocol,
         leitner: Leitner,
         voiceSpeech: AVSpeechSynthesisVoiceProtocol,
         synthesizer: AVSpeechSynthesizerProtocol = AVSpeechSynthesizer())
    {
        self.synthesizer = synthesizer
        self.viewContext = viewContext
        self.voiceSpeech = voiceSpeech
        self.leitner = leitner
        super.init()
        self.synthesizer.delegate = self
        setupObservers()
        fetchMoreQuestion()
    }

    fileprivate func setupObservers() {
        $searchText.sink { [weak self] newValue in
            self?.searchQuestion(searchText: newValue)
        }.store(in: &cancellableSet)

        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextWillSave).sink { newValue in
            let context = newValue.object as? NSManagedObjectContext
            context?.insertedObjects.forEach { object in
                if let question = object as? Question {
                    Task {
                        await MainActor.run {
                            withAnimation {
                                self.questions.insert(question, at: 0)
                                self.objectWillChange.send()
                            }
                        }
                    }
                }
            }
        }.store(in: &cancellableSet)
    }

    func fetchMoreQuestion() {
        let req = Question.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.question, ascending: true)]
        req.fetchLimit = count
        req.fetchOffset = offset
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "leitnerId == %i", leitner.id))
        if let selectedTag {
            predicates.append(NSPredicate(format: "ANY tag.name == %@", selectedTag.name ?? ""))
        }
        req.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)

        switch selectedSort {
        case .level:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.level?.level, ascending: true),
                                   NSSortDescriptor(keyPath: \Question.question, ascending: true),
                                   NSSortDescriptor(keyPath: \Question.createTime, ascending: true)]
        case .completed:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.completed, ascending: false), NSSortDescriptor(keyPath: \Question.createTime, ascending: false)]
        case .alphabet:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.question, ascending: true)]
        case .favorite:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.favorite, ascending: false), NSSortDescriptor(keyPath: \Question.favoriteDate, ascending: false)]
        case .date:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.createTime, ascending: false)]
        case .passedTime:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.passTime, ascending: false)]
        case .noTags:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.tagsCount, ascending: true), NSSortDescriptor(keyPath: \Question.createTime, ascending: false)]
        case .tags:
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.tagsCount, ascending: false), NSSortDescriptor(keyPath: \Question.createTime, ascending: false)]
        }
        do {
            questions.append(contentsOf: try viewContext.fetch(req))
            objectWillChange.send()
            offset += count
        } catch {
            print(error)
        }
    }

    func searchQuestion(searchText: String) {
        if searchText.count <= 2 || searchText.isEmpty || searchText == "#" {
            searchedQuestions = []
            return
        }

        let req = Question.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.question, ascending: true)]
        req.fetchLimit = 100
        if searchText.count > 0, searchText[searchText.startIndex] == "#" {
            let tagName = searchText.replacingOccurrences(of: "#", with: "")
            req.predicate = NSPredicate(format: "(ANY tag.name contains[c] %@) AND leitnerId == %i", tagName, leitner.id)
        } else if !searchText.isEmpty {
            req.predicate = NSPredicate(format: "(question contains[c] %@ OR answer contains[c] %@ OR detailDescription contains[c] %@) AND leitnerId == %i", searchText, searchText, searchText, leitner.id)
        }
        do {
            searchedQuestions = try viewContext.fetch(req)
        } catch {
            print(error)
        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { questions[$0] }.forEach(viewContext.delete)
            PersistenceController.saveDB(viewContext: viewContext)
            questions.remove(atOffsets: offsets)
        }
    }

    func delete(_ question: Question) {
        viewContext.delete(question)
        questions.removeAll(where: { $0 == question })
        PersistenceController.saveDB(viewContext: viewContext)
        objectWillChange.send() // notify to redrawn filtred items and delete selected question
    }

    func toggleCompleted(_ question: Question) {
        question.completed.toggle()
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func toggleFavorite(_ question: Question) {
        question.favorite.toggle()
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func resetToFirstLevel(_ question: Question) {
        if let firstLevel = Leitner.fetchLevelInsideLeitner(context: viewContext, leitnerId: leitner.id, level: 1) {
            question.level = firstLevel
            question.passTime = nil
            question.completed = false
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func pronounceOnce(_ question: Question) {
        _ = synthesizer.stopSpeaking(at: .immediate)
        pronounce(question)
        reviewStatus = .unInitialized
    }

    func pronounce(_ question: Question) {
        reviewStatus = .isPlaying
        let pronounceString = "\(question.question ?? "") \(pronounceDetailAnswer ? (question.detailDescription ?? "") : "")"
        let utterance = AVSpeechUtterance(string: pronounceString)
        if voiceSpeech is AVSpeechSynthesisVoice {
            utterance.voice = voiceSpeech as? AVSpeechSynthesisVoice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1
        if !selectedVoiceIdentifire.isEmpty {
            utterance.voice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifire)
        }
        utterance.postUtteranceDelay = 0
        synthesizer.speak(utterance)
    }

    var timer: Timer?
    var lastPlayedQuestion: Question?
    func playReview() {
        reviewStatus = .isPlaying
        if synthesizer.isPaused {
            _ = synthesizer.continueSpeaking()
        } else if lastPlayedQuestion != nil {
            // this play because of pause method stop timer and at the result next not called anymore
            withAnimation {
                playNext()
            }
        } else if lastPlayedQuestion == nil, let firstQuestion = questions.first {
            pronounce(firstQuestion)
            lastPlayedQuestion = firstQuestion
        } else if let firstQuestion = questions.first {
            pronounce(firstQuestion)
            lastPlayedQuestion = firstQuestion
        }
    }

    func playNext() {
        if !hasNext() {
            return
        }
        if let lastPlayedQuestion = lastPlayedQuestion, let index = questions.firstIndex(of: lastPlayedQuestion), questions.indices.contains(index + 1) {
            let nextQuestion = questions[index + 1]
            pronounce(nextQuestion)
            self.lastPlayedQuestion = nextQuestion
        }
    }

    func playNextImmediately() {
        _ = synthesizer.stopSpeaking(at: .immediate)
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        playNext()
    }

    func hasNext() -> Bool {
        if let lastPlayedQuestion = lastPlayedQuestion, let index = questions.firstIndex(of: lastPlayedQuestion), questions.indices.contains(index + 1) {
            return true
        } else {
            let beforeCount = questions.count
            fetchMoreQuestion()
            let afterCount = questions.count
            if afterCount == beforeCount {
                finished()
                return false
            } else {
                return true
            }
        }
    }

    func pauseReview() {
        reviewStatus = .isPaused
        task?.cancel()
        if synthesizer.isSpeaking {
            _ = synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
    }

    func stopReview() {
        _ = synthesizer.stopSpeaking(at: .immediate)
        reviewStatus = .unInitialized
        task?.cancel()
        lastPlayedQuestion = nil
    }

    func finished() {
        reviewStatus = .unInitialized
        lastPlayedQuestion = nil
    }

    var reviewdCount: Int {
        if let lastPlayedQuestion = lastPlayedQuestion, let index = questions.firstIndex(of: lastPlayedQuestion) {
            return index + 1
        } else {
            return 0
        }
    }

    func moveQuestionTo(_ question: Question, leitner: Leitner) {
        question.level = leitner.firstLevel
        question.passTime = nil
        question.completed = false
        question.leitner = leitner
        PersistenceController.saveDB(viewContext: viewContext)
        questions.removeAll(where: { $0 == question })
        objectWillChange.send()
    }

    func viewDidAppear() {
        commandCenter = MPRemoteCommandCenter.shared()
        commandCenter?.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.togglePlayPauseReview()
            return .success
        }
        commandCenter?.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.togglePlayPauseReview()
            return .success
        }
    }

    func togglePlayPauseReview() {
        if reviewStatus == .isPlaying {
            pauseReview()
        } else {
            playReview()
        }
    }

    func reload() {
        selectedTag = nil
        selectedSort = .date
        questions = []
        offset = 0
        fetchMoreQuestion()
    }

    func sort(_ sort: SearchSort, _ tag: Tag? = nil) {
        selectedTag = tag
        selectedSort = sort
        questions = []
        offset = 0
        fetchMoreQuestion()
    }

    func complete(_ question: Question) {
        if let lastLevel = leitner.levels.first(where: { $0.level == 13 }) {
            question.level = lastLevel
            question.passTime = Date()
            question.completed = true
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func pauseSpeaking() {
        _ = synthesizer.pauseSpeaking(at: .immediate)
    }

    func resumeSpeaking() {
        if synthesizer.isPaused, reviewStatus == .isPlaying {
            playReview()
        }
    }

    func speechSynthesizer(_: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance) {
        if hasNext() == true {
            timerTask()
        } else {
            finished()
        }
    }

    func timerTask() {
        task = Task { [weak self] in
            guard !Task.isCancelled else { return }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run { [weak self] in
                self?.playNext()
            }
        }
    }
}

var searchSorts: [SortModel] = [
    .init(iconName: "textformat.abc", title: "Alphabet", sortType: .alphabet),
    .init(iconName: "arrow.up.arrow.down.square", title: "Level", sortType: .level),
    .init(iconName: "calendar.badge.clock", title: "Create Date", sortType: .date),
    .init(iconName: "calendar.badge.clock", title: "Passed Date", sortType: .passedTime),
    .init(iconName: "star", title: "Favorite", sortType: .favorite),
    .init(iconName: "flag.2.crossed", title: "Completed", sortType: .completed),
    .init(iconName: "tag", title: "Tags", sortType: .tags),
    .init(iconName: "tag.slash", title: "Without Tags", sortType: .noTags),
]

struct SortModel: Hashable {
    let iconName: String
    let title: String
    let sortType: SearchSort
}

enum SearchSort {
    case level
    case completed
    case alphabet
    case favorite
    case date
    case passedTime
    case tags
    case noTags
}
