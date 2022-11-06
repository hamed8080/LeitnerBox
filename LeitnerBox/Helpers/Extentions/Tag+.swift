//
// Tag+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
import SwiftUI
extension Tag {
    var tagSwiftUIColor: Color? {
        guard let uicColor = color as? UIColor else { return nil }
        return Color(uiColor: uicColor)
    }

    var questions: [Question] {
        question?.allObjects as? [Question] ?? []
    }
}
