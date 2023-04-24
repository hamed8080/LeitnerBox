//
// StatisticsViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation
import SwiftUI
import Combine

final class StatisticsViewModel: ObservableObject {
    var viewContext: NSManagedObjectContext
    @Published var statistics: [Statistic] = []
    @Published var timeframe: Timeframe = .week
    var cancelableSet = Set<AnyCancellable>()
    private(set) var isLoading: Bool = false

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        $timeframe.sink { [weak self] timeFrame in
            self?.load(timeframe: timeFrame)
        }
        .store(in: &cancelableSet)
    }

    func save() {
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func load(timeframe: Timeframe = .week) {
        isLoading = true
        viewContext.perform {
            let req = Statistic.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(keyPath: \Statistic.actionDate, ascending: true)]
            req.predicate = NSPredicate(format: "actionDate >= %@", self.startDate(timeframe: timeframe) as NSDate)
            var statistics: [Statistic] = []
            do {
                statistics = try self.viewContext.fetch(req)
            } catch {
                print("Fetch failed: Error \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.statistics = statistics
                self.isLoading = false
            }
        }
    }

    func startDate(timeframe: Timeframe) -> Date {
        switch timeframe {
        case .today:
            return Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? Date()
        case .week:
            return Calendar.current.date(byAdding: .weekday, value: -8, to: .now) ?? Date()
        case .month:
            return Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? Date()
        case .year:
            return Calendar.current.date(byAdding: .year, value: -5, to: .now) ?? Date()
        }
    }

    var plottables: [PloatableItem] {
        plotables(statistics, isPassed: true) + plotables(statistics, isPassed: false)
    }

    private func plotables(_ array: [Statistic], isPassed: Bool) -> [PloatableItem] {
        var arr: [PloatableItem] = []
        array.filter { $0.isPassed == isPassed }.forEach { statistic in
            // if exist add count
            if let index = arr.firstIndex(where: { $0.date.isInInSameDay(statistic.actionDate) && $0.isPassed == isPassed }) {
                arr[index].count += 1
            } else {
                // add new Item to array and set count to 1
                let day = PloatableItem(count: 1, date: statistic.actionDate?.startOfDay ?? Date(), isPassed: isPassed)
                arr.append(day)
            }
        }
        return arr
    }

    func reset() {
        statistics = []
    }
}

struct PloatableItem: Hashable {
    var count: Int
    let date: Date
    let isPassed: Bool
}

public enum Timeframe: String, Hashable, CaseIterable, Sendable {
    case today
    case week
    case month
    case year
}
