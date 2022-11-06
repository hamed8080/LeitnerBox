//
// Synonym+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
extension Synonym {
    var allQuestions: [Question] {
        question?.allObjects as? [Question] ?? []
    }
}
