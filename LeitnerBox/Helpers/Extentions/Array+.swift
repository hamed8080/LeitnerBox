//
// Array+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation
extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        other.count == count && other.sorted() == sorted()
    }

    func isContainsArray(of other: [Element]) -> Bool {
        var isContainsSameItems = true
        for item in self where other.contains(item) == false {
            isContainsSameItems = false
        }
        return isContainsSameItems
    }
}
