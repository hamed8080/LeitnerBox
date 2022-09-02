//
// DateEx.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import Foundation
extension Date {
    func differenceWith(from date: Date) -> DateComponents {
        let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: self)
        return diffs
    }
}
