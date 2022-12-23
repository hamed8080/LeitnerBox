//
//  AVSpeechSynthesisVoiceProtocol.swift
//  LeitnerBox
//
//  Created by hamed on 12/22/22.
//
import AVFoundation
import Foundation

protocol AVSpeechSynthesizerProtocol {
    var isPaused: Bool { get }
    var isSpeaking: Bool { get }
    var delegate: AVSpeechSynthesizerDelegate? { get set }
    func speak(_ utterance: AVSpeechUtterance)
    func pauseSpeaking(at: AVSpeechBoundary) -> Bool
    func continueSpeaking() -> Bool
    func stopSpeaking(at: AVSpeechBoundary) -> Bool
}

protocol AVSpeechSynthesisVoiceProtocol {}

extension AVSpeechSynthesisVoice: AVSpeechSynthesisVoiceProtocol {}

extension AVSpeechSynthesizer: AVSpeechSynthesizerProtocol {}
