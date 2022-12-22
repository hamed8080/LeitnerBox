//
//  MockAVSpeechSynthesisVoice.swift
//  LeitnerBoxTests
//
//  Created by hamed on 12/22/22.
//

@testable import LeitnerBox
import Foundation
import AVFoundation

class MockAVSpeechSynthesizer: NSObject, AVSpeechSynthesizerProtocol {
    var isPaused: Bool = true
    var isSpeaking: Bool = false
    var delegate: AVSpeechSynthesizerDelegate?

    func speak(_ utterance: AVSpeechUtterance) {
    }

    func pauseSpeaking(at: AVSpeechBoundary) -> Bool {
        return true
    }

    func continueSpeaking() -> Bool {
        return true
    }

    func stopSpeaking(at: AVSpeechBoundary) -> Bool {
        return true
    }
}

class MockAVSpeechSynthesisVoice: NSObject, AVSpeechSynthesisVoiceProtocol {

}
