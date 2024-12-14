//
//  LeitnerBoxOpusConverter.swift
//  LeitnerBox
//
//  Created by Hamed Hosseini on 12/14/24.
//

import Foundation
import ffmpegkit

class LeitnerBoxOpusConverter {
    private init(path: URL) {}

    public static func isOpus(path: URL) async -> Bool {
        typealias Comepletion = CheckedContinuation<Bool, Never>
        return await withCheckedContinuation { (result: Comepletion) in
            isOpusAudio(path: path) { isOpus in
                result.resume(returning: isOpus)
            }
        }
    }

    private static func isOpusAudio(path: URL, _ completion: @escaping (Bool) -> Void) {
        FFprobeKit.executeAsync("-v quiet -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \(path)") { session in
            let output = session?.getOutput()
            let codecName = output?.trimmingCharacters(in: .whitespacesAndNewlines)
            let isOpus = codecName == "opus"
            completion(isOpus)
        }
    }

    public static func convert(_ fileURL: URL) async -> URL? {
        typealias Completion = CheckedContinuation<URL?, Never>
        return await withCheckedContinuation { (result: Completion) in
            convertAudio(fileURL) { url in
                result.resume(returning: url)
            }
        }
    }

    private static func convertAudio(_ fileURL: URL, _ completion: @escaping (URL?) -> Void){
        guard
            let output = convertedFileURL(fileURL),
            let convertedDIR = LeitnerBoxOpusConverter.convertedDIRURL
        else {
            completion(nil)
            return
        }
        let path = fileURL
        createConvertDir(convertedDIR)
        removeOldFile(output)

        FFmpegKit.executeAsync("-i \(path.path()) -vn -c:a aac \(output.path())") { session in
            let returnCode = session?.getReturnCode()
            if ReturnCode.isSuccess(returnCode) {
                completion(output)
            } else {
                completion(nil)
            }
        }
    }

    private static func createConvertDir(_ convertedDIR: URL) {
        if !FileManager.default.fileExists(atPath: convertedDIR.path())  {
            do {
                try FileManager.default.createDirectory(atPath: convertedDIR.path(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
    }

    private static func removeOldFile(_ output: URL) {
        // Check if the file already exists, and if so, remove it
        if FileManager.default.fileExists(atPath: output.path()) {
            do {
                try FileManager.default.removeItem(atPath: output.path())
                print("Existing file removed successfully.")
            } catch {
                print("Error removing existing file: \(error)")
                return
            }
        }
    }
    
    private static var convertedDIRURL: URL? {
        let docDIR = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return docDIR?.appending(path: "converted")
    }

    public static func convertedFileURL(_ fileURL: URL) -> URL? {
        let fileName = fileURL.lastPathComponent
        return LeitnerBoxOpusConverter.convertedDIRURL?.appending(path: "\(fileName).mp4")
    }
}
