//
// ReviewViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import Foundation
import NaturalLanguage
import SwiftUI

final class ReviewViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContextProtocol
    @Published var questions: [Question] = []
    @Published var showDelete = false
    @Published var level: Level
    @Published var failedCount = 0
    @Published var passCount = 0
    @Published var selectedQuestion: Question?
    @Published var isShowingAnswer = false
    @Published var totalCount = 0
    @Published var isFinished = false
    @Published var leitner: Leitner?
    @AppStorage("pronounceDetailAnswer") private var pronounceDetailAnswer = false
    @Published var tags: [Tag] = []
    var synthesizer: AVSpeechSynthesizerProtocol
    private var voiceSpeech: AVSpeechSynthesisVoiceProtocol

    init(viewContext: NSManagedObjectContextProtocol, levelValue: Int16, leitnerId: Int64, voiceSpeech: AVSpeechSynthesisVoiceProtocol, synthesizer: AVSpeechSynthesizerProtocol = AVSpeechSynthesizer()) {
        self.viewContext = viewContext
        self.voiceSpeech = voiceSpeech
        self.synthesizer = synthesizer

        let levelReq = Level.fetchRequest()
        levelReq.predicate = NSPredicate(format: "leitner.id == %i AND level == %i", leitnerId, levelValue)
        let level = (try? viewContext.fetch(levelReq).first) ?? .init()
        self.level = level
        leitner = level.leitner

        let req = Question.fetchRequest()
        req.predicate = NSPredicate(format: "level.level == %d && level.leitner.id == %d", levelValue, leitner?.id ?? 0)
        do {
            questions = try viewContext.fetch(req).filter(\.isReviewable).shuffled()
            totalCount = questions.count
            isFinished = totalCount == 0
            preapareNext(questions.first)
            loadTags()
        } catch {
            print(error)
        }
    }

    func deleteQuestion() {
        if let selectedQuestion {
            viewContext.delete(selectedQuestion)
            save()
            toggleDeleteDialog()
        }
        removeFromList()
        if !hasNext {
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }

    func toggleFavorite() {
        selectedQuestion?.favorite.toggle()
        save()
        objectWillChange.send()
    }

    func pass() {
        isShowingAnswer = false
        passCount += 1
        selectedQuestion?.passTime = Date()
        if selectedQuestion?.levelValue == 13 {
            selectedQuestion?.completed = true
        } else {
            selectedQuestion?.level = selectedQuestion?.upperLevel
        }

        let statistic = Statistic(context: viewContext.computedContext)
        statistic.question = selectedQuestion
        statistic.actionDate = Date()
        statistic.isPassed = true
        selectedQuestion?.statistics?.adding(statistic)

        save()
        removeFromList()
        if !hasNext {
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }

    func fail() {
        isShowingAnswer = false
        let statistic = Statistic(context: viewContext.computedContext)
        statistic.question = selectedQuestion
        statistic.actionDate = Date()
        statistic.isPassed = false
        selectedQuestion?.statistics?.adding(statistic)

        if leitner?.backToTopLevel == true {
            selectedQuestion?.level = selectedQuestion?.firstLevel
            selectedQuestion?.completed = false
        }
        save()
        failedCount += 1
        removeFromList()
        if !hasNext {
            isFinished = true
            return
        }
        preapareNext(questions.first)
    }

    func removeFromList() {
        if let selectedQuestion {
            questions.removeAll(where: { $0 == selectedQuestion })
        }
    }

    func toggleDeleteDialog() {
        showDelete.toggle()
    }

    var hasNext: Bool {
        questions.count > 0
    }

    func pronounce() {
        guard let question = selectedQuestion else { return }
        _ = synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: "\(question.question ?? "") \(pronounceDetailAnswer ? (question.detailDescription ?? "") : "")")
        if voiceSpeech is AVSpeechSynthesisVoice {
            utterance.voice = voiceSpeech as? AVSpeechSynthesisVoice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1
        utterance.postUtteranceDelay = 0
        synthesizer.speak(utterance)
    }

    func copyQuestionToClipboard() {
        guard let selectedQuestion = selectedQuestion else { return }
        UIPasteboard.general.string = [selectedQuestion.question, selectedQuestion.answer, selectedQuestion.detailDescription]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    func toggleAnswer() {
        isShowingAnswer.toggle()
    }

    func preapareNext(_ question: Question?) {
        selectedQuestion = question
    }

    func loadTags() {
        guard let leitnerId = leitner?.id else { return }
        let predicate = NSPredicate(format: "leitner.id == %d", leitnerId)
        let req = Tag.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        do {
            tags = try viewContext.fetch(req)
        } catch {
            print(error)
        }
    }

    var partOfspeech: String? {
        let text = String((selectedQuestion?.question ?? "").split(separator: "\n").first ?? "")
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        var tags: [String] = []
        tagger.enumerateTags(in: text.startIndex ..< text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, _ in
            if let tag = tag {
                tags.append("\(tag.rawValue)")
            }
            return true
        }
        return tags.joined(separator: ", ")
    }

    func stopPronounce() {
        _ = synthesizer.stopSpeaking(at: .immediate)
    }

    func save() {
        PersistenceController.saveDB(viewContext: viewContext)
    }
}
