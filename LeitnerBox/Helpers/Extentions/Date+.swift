//
// Date+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
extension Date {
    func differenceWith(from date: Date) -> DateComponents {
        let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: self)
        return diffs
    }

    func isInInSameDay(_ date: Date?) -> Bool {
        guard let date else { return false }
        return Calendar.current.isDate(self, inSameDayAs: date)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
