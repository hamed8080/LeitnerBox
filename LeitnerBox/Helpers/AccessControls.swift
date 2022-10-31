//
// AccessControls.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation

enum AccessControls: CaseIterable, Comparable {
    case question
    case detail
    case answer
    case level
    case showTags
    case showSynonyms
    case addTag
    case addSynonym
    case removeTag
    case removeSynonym
    case delete
    case edit
    case microphone
    case favorite
    case copy
    case reset
    case completed
    case move
    case more
    case trailingControls
    case saveDirectly
}

extension AccessControls {
    static let full: [AccessControls] = AccessControls.allCases.filter{$0 != .saveDirectly}
    static let normal: [AccessControls] = [.question, .detail, .answer, .level, .showTags, .showSynonyms]
    static let normalWithoutTagsAndSynonyms: [AccessControls] = [.question, .detail, .answer, .level]
}
