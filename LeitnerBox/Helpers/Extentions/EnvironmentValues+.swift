//
//  EnvironmentValues+.swift
//  LeitnerBox
//
//  Created by hamed on 10/29/22.
//

import Foundation
import AVFoundation
import SwiftUI

private struct AVSpeechEnvironmentKey: EnvironmentKey {
    static let defaultValue: AVSpeechSynthesisVoice = AVSpeechSynthesisVoice(language: "en-GB")!
}

extension EnvironmentValues {
    var avSpeechSynthesisVoice: AVSpeechSynthesisVoice {
        get { self[AVSpeechEnvironmentKey.self] }
        set { self[AVSpeechEnvironmentKey.self] = newValue }
    }
}
