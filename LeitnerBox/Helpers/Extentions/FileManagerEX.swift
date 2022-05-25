//
//  FileManagerEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/24/22.
//

import Foundation

extension FileManager {

    func urlForUniqueTemporaryDirectory(preferredName: String? = nil) throws -> (url: URL, deleteDirectory: () throws -> Void) {
        let basename = preferredName ?? UUID().uuidString

        var counter = 0
        var createdSubdirectory: URL? = nil
        repeat {
            do {
                let subdirName = counter == 0 ? basename : "\(basename)-\(counter)"
                let subdirectory = temporaryDirectory.appendingPathComponent(subdirName, isDirectory: true)
                try createDirectory(at: subdirectory, withIntermediateDirectories: false)
                createdSubdirectory = subdirectory
            } catch CocoaError.fileWriteFileExists {
                // Catch file exists error and try again with another name.
                // Other errors propagate to the caller.
                counter += 1
            }
        } while createdSubdirectory == nil

        let directory = createdSubdirectory!
        let deleteDirectory: () throws -> Void = {
            try self.removeItem(at: directory)
        }
        return (directory, deleteDirectory)
    }
    
    var appGroupFolederURL:URL?{
        let fm = FileManager.default
        return fm.containerURL(forSecurityApplicationGroupIdentifier: AppGroupLocalStorage.groupName)        
    }
    
    var appGroupDBFolder:URL?{
        return appGroupFolederURL?.appendingPathComponent("DB/", isDirectory: true)
    }
}


struct TemporaryFile {
    let directoryURL: URL
    let fileURL: URL
    
    let deleteDirectory: () throws -> Void
    
    init(creatingTempDirectoryForFilename filename: String) throws {
        let (directory, deleteDirectory) = try FileManager.default.urlForUniqueTemporaryDirectory()
        self.directoryURL = directory
        self.fileURL = directory.appendingPathComponent(filename)
        self.deleteDirectory = deleteDirectory
    }
}
