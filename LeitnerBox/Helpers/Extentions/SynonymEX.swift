//
// SynonymEX.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/19/22.

import Foundation
extension Synonym {
    var allQuestions: [Question] {
        question?.allObjects as? [Question] ?? []
    }
}
