//
// LevelsViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import Combine
import CoreData
import Foundation
import SwiftUI

struct LevelRowData: Identifiable {
    var id: NSManagedObjectID { level.objectID }
    let leitnerId: Int
    let level: Level
    let favCount: Int
    let reviewableCount: Int
    let totalCountInsideLevel: Int
    var notCompletdCount: Int { totalCountInsideLevel - reviewableCount }
}

class LevelsViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContext
    var leitner: Leitner
    @Published var searchWord: String = ""
    var levels: [LevelRowData] = []
    @Published var selectedLevel: Level?
    @Published var searchedQuestions: [Question] = []
    private(set) var cancellableSet: Set<AnyCancellable> = []
    var totalCount: Int = 0
    var completedCount: Int = 0
    var reviewableCount: Int = 0
    @Published var isSearching: Bool = false

    init(viewContext: NSManagedObjectContext, leitner: Leitner) {
        self.viewContext = viewContext
        self.leitner = leitner
        load()
        $searchWord.sink { [weak self] newValue in
            self?.fetchQuestions(newValue)
        }
        .store(in: &cancellableSet)

        $isSearching.dropFirst().sink { [weak self] newValue in
            if newValue == false {
                self?.searchedQuestions = []
            }
        }
        .store(in: &cancellableSet)

        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave).sink { _ in
            Task {
                await MainActor.run {
                    self.load()
                }
            }
        }.store(in: &cancellableSet)
    }

    func fetchQuestions(_ searchWord: String) {
        if searchWord.count == 1 || searchWord.isEmpty || searchWord == "#" {
            searchedQuestions = []
            return
        }

        let isTag = searchWord[searchWord.startIndex] == "#"
        let tagName = searchWord.replacingOccurrences(of: "#", with: "")
        let req = Question.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Question.question, ascending: true)]
        req.fetchLimit = 20
        if isTag, !tagName.isEmpty {
            req.predicate = NSPredicate(format: "ANY tag.name == [c] %@", tagName)
        } else {
            req.predicate = NSPredicate(format: "question contains[c] %@ OR answer contains[c] %@ OR detailDescription contains[c] %@", searchWord, searchWord, searchWord)
        }
        if let questions = try? viewContext.fetch(req) {
            searchedQuestions = questions
        }
    }

    func load() {
        let leitnerId = leitner.id
        let levels = Leitner.fetchLevelsInsideLeitner(context: viewContext, leitnerId: leitnerId)
        totalCount = Leitner.fetchLeitnerQuestionsCount(context: viewContext, leitnerId: leitnerId)
        completedCount = Level.fetchCompletedCount(context: viewContext, leitnerId: leitnerId)
        var rowDatas: [LevelRowData] = []
        levels.forEach { level in
            let favCount = Level.fetchFavCountInsideLevel(context: viewContext, level: level.level, leitnerId: leitnerId)
            let reviewableCount = Level.fetchReviewableCountInsideLevel(context: viewContext, level: level, leitnerId: leitnerId)
            let totalCount = Level.fetchTotalCountInsideLevel(context: viewContext, level: level.level, leitnerId: leitnerId)
            rowDatas.append(
                .init(
                    leitnerId: Int(leitnerId),
                    level: level,
                    favCount: favCount,
                    reviewableCount: reviewableCount,
                    totalCountInsideLevel: totalCount
                )
            )
        }
        let reviewableCount = rowDatas.map(\.reviewableCount).reduce(0, +)
        self.levels = rowDatas
        self.reviewableCount = reviewableCount
        objectWillChange.send()
    }
}
