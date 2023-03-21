//
// StatisticsViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation
import SwiftUI

final class StatisticsViewModel: ObservableObject {
    var viewContext: NSManagedObjectContext
    @Published var statistics: [Statistic] = []
    @Published var timeframe: Timeframe = .week

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func save() {
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func load() {
        let req = Statistic.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Statistic.actionDate, ascending: true)]
        do {
            statistics = try viewContext.fetch(req)
        } catch {
            print("Fetch failed: Error \(error.localizedDescription)")
        }
    }

    private func byWeek() -> [Statistic] {
        let lastWeek = Calendar.current.date(byAdding: .weekday, value: -8, to: .now)
        return statistics.filter { lastWeek?.timeIntervalSince1970 ?? 0 <= $0.actionDate?.timeIntervalSince1970 ?? 0 }
    }

    private func byMonth() -> [Statistic] {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now)
        return statistics.filter { lastMonth?.timeIntervalSince1970 ?? 0 <= $0.actionDate?.timeIntervalSince1970 ?? 0 }
    }

    private func byYear() -> [Statistic] {
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: .now)
        return statistics.filter { lastYear?.timeIntervalSince1970 ?? 0 <= $0.actionDate?.timeIntervalSince1970 ?? 0 }
    }

    private func successOfWeek() -> [[IndexingIterator<[Statistic]>.Element]] {
        let gorupedByDate = byWeek().groupSort(byDate: { $0.actionDate ?? Date() })
        return gorupedByDate
    }

    private func stateByPassed() -> [[Statistic]] {
        [byWeek().filter(\.isPassed), byWeek().filter { $0.isPassed == false }]
    }

    private func weekPlotable() -> [PloatableItem] {
        let data = byWeek()
        return totolPlottables(data: data)
    }

    private func monthPlotable() -> [PloatableItem] {
        let data = byMonth()
        return totolPlottables(data: data)
    }

    private func yearPlotable() -> [PloatableItem] {
        let data = byYear()
        return totolPlottables(data: data)
    }

    private func totolPlottables(data: [Statistic]) -> [PloatableItem] {
        plotables(data, isPassed: true) + plotables(data, isPassed: false)
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

    var plaotsForSelectedTime: [PloatableItem] {
        switch timeframe {
        case .today:
            fatalError("not implemented")
        case .week:
            return weekPlotable()
        case .month:
            return monthPlotable()
        case .year:
            return yearPlotable()
        }
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
