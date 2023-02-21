//
// SynonymViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Combine
import CoreData
import Foundation
import SwiftUI

class SynonymViewModel: ObservableObject {
    @Published var leitner: Leitner
    @Published var baseQuestion: Question?
    @Published var viewContext: NSManagedObjectContext
    @Published var searchText: String = ""
    @Published var searchedQuestions: [Question] = []
    private(set) var cancellableSet: Set<AnyCancellable> = []

    init(viewContext: NSManagedObjectContext, leitner: Leitner, baseQuestion: Question? = nil) {
        self.viewContext = viewContext
        self.baseQuestion = baseQuestion
        self.leitner = leitner
        $searchText.sink { [weak self] _ in
            self?.fetchQuestions()
        }
        .store(in: &cancellableSet)
    }

    func fetchQuestions() {
        if searchText.count == 1 || searchText.isEmpty {
            searchedQuestions = []
            return
        }
        let req = Question.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.question, ascending: true)]
        req.fetchLimit = 20
        req.predicate = NSPredicate(format: "question contains[c] %@ OR answer contains[c] %@ OR detailDescription contains[c] %@", searchText, searchText, searchText)
        if let questions = try? viewContext.fetch(req) {
            searchedQuestions = questions
        }
    }

    func addAsSynonym(_: Question) {
//        guard let baseQuestion else { return }
//        withAnimation {
//            let synonym = baseQuestion.synonymsArray?.first ?? quesiton.synonymsArray?.first ?? Synonym(context: viewContext)
//            synonym.addToQuestion(quesiton)
//            synonym.addToQuestion(baseQuestion)
//            objectWillChange.send()
//        }
    }

    func addSynonymToQuestion(_ question: Question, _ synonymQuestion: Question) {
        withAnimation {
            if let synonym = question.synonyms?.allObjects.first as? Synonym {
                synonymQuestion.addToSynonyms(synonym)
            } else {
                let synonym = Synonym(context: viewContext)
                synonym.addToQuestion(question)
                synonymQuestion.addToSynonyms(synonym)
            }
            try? PersistenceController.shared.viewContext.save()
        }
    }

    func removeQuestionFromSynonym(_ question: Question) {
        if let synonym = question.synonyms?.allObjects.first as? Synonym {
            question.removeFromSynonyms(synonym)
        }
        try? PersistenceController.shared.viewContext.save()
    }

    var allSynonymsInLeitner: [Synonym] {
        let req = Synonym.fetchRequest()
        return (try? viewContext.fetch(req)) ?? []
    }

    /// We want the user keep all ``searchText`` and list of ``searchedQuestions``
    func reset() {
        baseQuestion = nil
    }
}
