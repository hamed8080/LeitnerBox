//
// LevelsViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/14/22.

import AVFoundation
import CoreData
import Foundation
import SwiftUI

class LevelsViewModel: ObservableObject {
    @Published
    var viewContext: NSManagedObjectContext

    @Published
    var leitner: Leitner

    @Published
    var searchWord: String = ""

    @Published
    var levels: [Level] = []

    @Published
    var showDaysAfterDialog = false

    @Published
    var selectedLevel: Level? = nil

    @Published
    var daysToRecommend = 0

    var filtered: [Question] {
        if searchWord.isEmpty || searchWord == "#" {
            return []
        }
        let tagName = searchWord.replacingOccurrences(of: "#", with: "")
        if searchWord.contains("#"), tagName.isEmpty == false {
            return leitner.allQuestions.filter {
                $0.tagsArray?.contains(where: { $0.name?.lowercased().contains(tagName.lowercased()) ?? false }) ?? false
            }
        }
        return leitner.allQuestions.filter {
            $0.question?.lowercased().contains(searchWord.lowercased()) ?? false ||
                $0.answer?.lowercased().contains(searchWord.lowercased()) ?? false ||
                $0.detailDescription?.lowercased().contains(searchWord.lowercased()) ?? false
        }
    }

    init(viewContext: NSManagedObjectContext, leitner: Leitner) {
        self.viewContext = viewContext
        self.leitner = leitner
        load()
    }

    func saveDaysToRecommned() {
        selectedLevel?.daysToRecommend = Int32(daysToRecommend)
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func load() {
        let predicate = NSPredicate(format: "leitner.id == %d", leitner.id)
        let req = Level.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Level.level, ascending: true)]
        req.predicate = predicate
        levels = (try? viewContext.fetch(req)) ?? []
    }
}
