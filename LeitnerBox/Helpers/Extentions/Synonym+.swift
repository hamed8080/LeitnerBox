//
// Synonym+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation

extension Synonym {
    var allQuestions: [Question] {
        question?.allObjects as? [Question] ?? []
    }

    static func allSynonyms(context: NSManagedObjectContextProtocol, question: String) -> [Question] {
        let req = Synonym.fetchRequest()
        req.predicate = NSPredicate(format: "ANY question.question == %@", question)
        let synonyms = (try? context.fetch(req)) ?? []
        let questions = synonyms.compactMap(\.question?.allObjects).flatMap { $0 }.compactMap { $0 as? Question }
        return questions
    }
}
