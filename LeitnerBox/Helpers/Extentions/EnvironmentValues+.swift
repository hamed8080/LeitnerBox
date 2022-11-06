//
// EnvironmentValues+.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/29/22.

import AVFoundation
import Foundation
import SwiftUI

private struct AVSpeechEnvironmentKey: EnvironmentKey {
    static let defaultValue: AVSpeechSynthesisVoice = .init(language: "en-GB")!
}

extension EnvironmentValues {
    var avSpeechSynthesisVoice: AVSpeechSynthesisVoice {
        get { self[AVSpeechEnvironmentKey.self] }
        set { self[AVSpeechEnvironmentKey.self] = newValue }
    }
}
