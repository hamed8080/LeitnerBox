//
//  DownloadAndPlayButton.swift
//  LeitnerBox
//
//  Created by Hamed Hosseini on 12/14/24.
//

import SwiftUI
import ffmpegkit
import AVFoundation

struct DownloadAndPlayButton: View {
    let question: Question
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        HStack {
            button
            Spacer()
        }
    }
    
    private var button: some View {
        Button {
            Task {
                do {
                    try await downloadOrPlay()
                } catch {
                    print("error on download/convert the file: \(error)")
                }
            }
        } label: {
            HStack {
                Image(systemName: "waveform.badge.microphone")
                    .foregroundStyle(Color("AccentColor"))
            }
            .padding()
            .clipShape(RoundedCorner(radius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("AccentColor"), lineWidth: 1)
            }
        }
    }
    
    private func downloadOrPlay() async throws {
        let base = "188.132.192.219"
        
        if let word = question.question, let url = URL(string: "http://\(base)/\(word).opus") {
            
            guard let docDIR = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileURL = docDIR.appendingPathComponent("\(word)")
            
            if isExist(), let outputURL = LeitnerBoxOpusConverter.convertedFileURL(fileURL) {
                try play(fileURL: outputURL)
                return
            }
            
            // Download the file
            let req = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            let (data, _) = try await session.data(for: req)
            
            // Save to unconverted documents default folder
            let _ = FileManager.default.createFile(atPath: fileURL.path(), contents: data)
            
            // Convert to OPUS
            if let outputFile = await LeitnerBoxOpusConverter.convert(fileURL) {
                try play(fileURL: outputFile)
            }
        }
    }
    
    @MainActor
    public func play(fileURL: URL) throws {
        do {
            let audioData = try Data(contentsOf: fileURL, options: NSData.ReadingOptions.mappedIfSafe)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            player = try AVAudioPlayer(data: audioData, fileTypeHint: "mp4")
            player?.enableRate = true
            player?.play()
        } catch let error as NSError {
            print("error on playing the file: \(error)")
        }
    }
    
    private func isExist() -> Bool {
        guard
            let docDIR = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let word = question.question
        else { return false }
        let fileURL = docDIR.appendingPathComponent("\(word)")
        return FileManager.default.fileExists(atPath: fileURL.path())
    }
}

#Preview {
    DownloadAndPlayButton(question: Question())
}
