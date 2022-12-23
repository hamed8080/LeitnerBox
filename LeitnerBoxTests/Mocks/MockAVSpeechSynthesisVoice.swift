//
//  MockAVSpeechSynthesisVoice.swift
//  LeitnerBoxTests
//
//  Created by hamed on 12/22/22.
//

import AVFoundation
import Foundation
@testable import LeitnerBox

class MockAVSpeechSynthesizer: NSObject, AVSpeechSynthesizerProtocol {
    var isPaused: Bool = true
    var isSpeaking: Bool = false
    var delegate: AVSpeechSynthesizerDelegate?

    func speak(_: AVSpeechUtterance) {}

    func pauseSpeaking(at _: AVSpeechBoundary) -> Bool {
        true
    }

    func continueSpeaking() -> Bool {
        true
    }

    func stopSpeaking(at _: AVSpeechBoundary) -> Bool {
        true
    }
}

class MockAVSpeechSynthesisVoice: NSObject, AVSpeechSynthesisVoiceProtocol {}
