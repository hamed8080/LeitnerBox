//
// SearchViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
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
    @Published var viewContext: NSManagedObjectContext
    @Published var searchText: String = ""
    @Published var showLeitnersListDialog = false
    @Published var leitner: Leitner
    @Published var editQuestion: Question?
    @Published var selectedSort: SearchSort = .level
    @AppStorage("selectedVoiceIdentifire") var selectedVoiceIdentifire = ""
    @Published var reviewStatus: ReviewStatus = .unInitialized
    private(set) var sorted: [Question] = []
    var synthesizer: AVSpeechSynthesizerProtocol
    var commandCenter: MPRemoteCommandCenter?
    private var voiceSpeech: AVSpeechSynthesisVoiceProtocol
    var task: Task<Void, Error>?
    var sortedTags: [Tag] { leitner.tagsArray.sorted(by: { $0.name ?? "" < $1.name ?? "" }) }

    init(viewContext: NSManagedObjectContext,
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
        sort(.date)
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { sorted[$0] }.forEach(viewContext.delete)
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func delete(_ question: Question) {
        viewContext.delete(question)
        sorted.removeAll(where: { $0 == question })
        PersistenceController.saveDB(viewContext: viewContext)
        objectWillChange.send() // notify to redrawn filtred items and delete selected question
    }

    func addSynonym(question: Question, synonymQuestion: Question) {
        if let firstSynonym = question.synonymsArray?.first {
            firstSynonym.addToQuestion(synonymQuestion)
        } else {
            let synonym = Synonym(context: viewContext)
            synonym.addToQuestion(question)
        }
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func sort(_ sort: SearchSort) {
        selectedSort = sort
        let all = leitner.allQuestions
        switch sort {
        case .level:
            sorted = all.sorted(by: {
                ($0.level?.level ?? 0, $1.createTime?.timeIntervalSince1970 ?? -1) < ($1.level?.level ?? 0, $0.createTime?.timeIntervalSince1970 ?? -1)
            })
        case .completed:
            sorted = all.sorted(by: { first, second in
                (first.completed ? 1 : 0, first.passTime?.timeIntervalSince1970 ?? -1) > (second.completed ? 1 : 0, second.passTime?.timeIntervalSince1970 ?? -1)
            })
        case .alphabet:
            sorted = all.sorted(by: {
                ($0.question?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") < ($1.question?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            })
        case .favorite:
            sorted = all.sorted(by: {
                ($0.favorite ? 1 : 0, $0.favoriteDate?.timeIntervalSince1970 ?? -1) > ($1.favorite ? 1 : 0, $1.favoriteDate?.timeIntervalSince1970 ?? -1)
            })
        case .date:
            sorted = all.sorted(by: {
                ($0.createTime?.timeIntervalSince1970 ?? -1) > ($1.createTime?.timeIntervalSince1970 ?? -1)
            })
        case .passedTime:
            sorted = all.sorted(by: {
                ($0.passTime?.timeIntervalSince1970 ?? -1) > ($1.passTime?.timeIntervalSince1970 ?? -1)
            })
        case .noTags:
            sorted = all.sorted(by: {
                ($0.tagsArray?.count ?? 0) < ($1.tagsArray?.count ?? 0)
            })
        case .tags:
            sorted = all.sorted(by: {
                ($0.tagsArray?.count ?? 0) > ($1.tagsArray?.count ?? 0)
            })
        }
    }

    func sortByTag(_ tag: Tag) {
        let all = leitner.allQuestions
        sorted = all.sorted { q1, q2 in
            (q1.tagsArray?.contains(where: { $0.objectID == tag.objectID }) ?? false) && !(q2.tagsArray?.contains(where: { $0.objectID == tag.objectID }) ?? false)
        }
        objectWillChange.send()
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
        if let firstLevel = leitner.levels.first(where: { $0.level == 1 }) {
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
        } else if lastPlayedQuestion == nil, let firstQuestion = sorted.first {
            pronounce(firstQuestion)
            lastPlayedQuestion = firstQuestion
        } else if let firstQuestion = sorted.first {
            pronounce(firstQuestion)
            lastPlayedQuestion = firstQuestion
        }
    }

    func playNext() {
        if let lastPlayedQuestion = lastPlayedQuestion, let index = sorted.firstIndex(of: lastPlayedQuestion), sorted.indices.contains(index + 1) {
            let nextQuestion = sorted[index + 1]
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
        if let lastPlayedQuestion = lastPlayedQuestion, let index = sorted.firstIndex(of: lastPlayedQuestion), sorted.indices.contains(index + 1) {
            return true
        } else {
            return false
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
        if let lastPlayedQuestion = lastPlayedQuestion, let index = sorted.firstIndex(of: lastPlayedQuestion) {
            return index + 1
        } else {
            return 0
        }
    }

    func moveQuestionTo(_ question: Question, leitner: Leitner) {
        question.level = leitner.firstLevel
        question.passTime = nil
        question.completed = false
        PersistenceController.saveDB(viewContext: viewContext)
        sorted.removeAll(where: { $0 == question })
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
        sort(selectedSort)
    }

    var filtered: [Question] {
        if searchText.isEmpty || searchText == "#" {
            return sorted
        }
        let tagName = searchText.replacingOccurrences(of: "#", with: "")
        if searchText.contains("#"), tagName.isEmpty == false {
            return sorted.filter {
                $0.tagsArray?.contains(where: { $0.name?.lowercased().contains(tagName.lowercased()) ?? false }) ?? false
            }
        } else {
            return sorted.filter {
                $0.question?.lowercased().contains(searchText.lowercased()) ?? false ||
                    $0.answer?.lowercased().contains(searchText.lowercased()) ?? false ||
                    $0.detailDescription?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
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
