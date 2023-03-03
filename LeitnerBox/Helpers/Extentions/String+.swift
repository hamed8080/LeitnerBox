//
// String+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
extension String {
    var persianAlphabet: [Character] {
        let characters = Array("وپضصثقفغعهخحجچشسیبلاتنمظطزرذدپًٌٍَُِّْؤئيإأآةكٓژٰ‌‌ٔء،۱۲۳۴۵۶۷۸۹۰")
        return characters
    }

    var isContainPersianCharacter: Bool {
        if isEmpty { return false }
        var isContains = false
        persianAlphabet.forEach { character in
            if self.contains(character) {
                isContains = true
            }
        }
        return isContains
    }

    func isLessThan(_ value: String) -> Bool {
        self < value
    }

    func isGreaterThan(_ value: String) -> Bool {
        self > value
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    func isLessThan(_ value: String?) -> Bool {
        self ?? "" < value ?? ""
    }

    func isGreaterThan(_ value: String?) -> Bool {
        self ?? "" > value ?? ""
    }
}
