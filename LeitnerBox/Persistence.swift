//
// Persistence.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

final class PersistenceController: ObservableObject {
    static let isTest: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_TEST"] == "1"
    static let inMemory = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" || isTest
    static var shared = PersistenceController(inMemory: inMemory)

    var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    var container: NSPersistentCloudKitContainer

    private init(inMemory: Bool = false) {
        UIColorValueTransformer.register()
        container = NSPersistentCloudKitContainer(name: "LeitnerBox")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        }
        Task {
            _ = try await container.loadPersistentStoresAsync
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    @MainActor
    func replaceDBIfExistFromShareExtension() {
        let appSuppportFile = moveAppGroupFileToAppSupportFolder()
        if let appSuppportFile {
            replaceDatabase(appSuppportFile: appSuppportFile)
        }
    }

    func moveAppGroupFileToAppSupportFolder() -> URL? {
        let fileManager = FileManager.default
        guard let appGroupDBFolder = fileManager.appGroupDBFolder else { return nil }
        if let contents = try? fileManager.contentsOfDirectory(atPath: appGroupDBFolder.path).filter({ $0.contains(".sqlite") }), contents.count > 0 {
            let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            let appGroupFile = appGroupDBFolder.appendingPathComponent(contents.first!)
            let appSuppportFile = appSupportDirectory!.appendingPathComponent(contents.first!)
            do {
                if fileManager.fileExists(atPath: appSuppportFile.path) {
                    try fileManager.removeItem(at: appSuppportFile) // to first delete old file and again replace with new one
                }
                try fileManager.moveItem(atPath: appGroupFile.path, toPath: appSuppportFile.path)
                return appSuppportFile
            } catch {
                print("Error to move appgroup file to app support folder\(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
        }
    }

    func replaceDatabase(appSuppportFile: URL) {
        do {
            let persistentCordinator = PersistenceController.shared.container.persistentStoreCoordinator
            guard let oldStore = persistentCordinator.persistentStores.first, let oldStoreUrl = oldStore.url else { return }
            try persistentCordinator.replacePersistentStore(at: oldStoreUrl, withPersistentStoreFrom: appSuppportFile, type: .sqlite)
            Task {
                _ = try await container.loadPersistentStoresAsync
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        } catch {
            print("error in restoring back up file\(error.localizedDescription)")
        }
    }

    class func saveDB(viewContext: NSManagedObjectContextProtocol, completionHandler: ((MyError) -> Void)? = nil) {
        do {
            try viewContext.save()
        } catch {
            print("error in save viewContext: ", error)
            completionHandler?(.failToSave)
        }
    }
}

extension NSPersistentCloudKitContainer {
    var loadPersistentStoresAsync: NSPersistentStoreDescription {
        get async throws {
            typealias LoadStoreContinuation = CheckedContinuation<NSPersistentStoreDescription, Error>
            return try await withCheckedThrowingContinuation { (continuation: LoadStoreContinuation) in
                loadPersistentStores { storeDescription, error in
                    if let error = error as NSError? {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: storeDescription)
                    }
                }
            }
        }
    }
}

// MARK: Generate the mock datas.

extension PersistenceController {
    func generateAndFillLeitner() -> [Leitner] {
        let leitners = generateLeitner(5)
        leitners.forEach { leitner in
            generateLevels(leitner: leitner).forEach { level in
                let questions = generateQuestions(20, level, leitner)
                generateTags(5, leitner).forEach { tag in
                    questions.forEach { question in
                        generateImages().forEach { image in
                            question.addToImages(image)
                        }
                        tag.addToQuestion(question)
                        generateStatistics(question)
                    }
                }
            }
        }
        PersistenceController.saveDB(viewContext: viewContext)
        return leitners
    }

    func generateLevels(leitner: Leitner) -> [Level] {
        var levels: [Level] = []
        for index in 1 ... 13 {
            let level = Level(context: viewContext)
            level.level = Int16(index)
            level.leitner = leitner
            level.daysToRecommend = 8
            levels.append(level)
        }
        return levels
    }

    func generateLeitner(_ count: Int) -> [Leitner] {
        var leitners: [Leitner] = []
        for index in 0 ..< count {
            let leitner = Leitner(context: viewContext)
            leitner.createDate = Date()
            leitner.name = "Leitner \(index)"
            leitner.id = Int64(index)
            leitners.append(leitner)
        }
        return leitners
    }

    func generateTags(_ count: Int, _ leitner: Leitner) -> [Tag] {
        var tags: [Tag] = []
        for index in 0 ..< count {
            let tag = Tag(context: viewContext)
            tag.name = "Tag \(index)-\(UUID().uuidString)"
            tag.color = UIColor.random()
            tag.leitner = leitner
            tags.append(tag)
        }
        return tags
    }

    func generateStatistics(_ question: Question) {
        let statistic = Statistic(context: viewContext)
        statistic.actionDate = Calendar.current.date(byAdding: .day, value: -(Int.random(in: 1 ... 360)), to: .now)
        statistic.isPassed = Bool.random()
        statistic.question = question
    }
    
    func generateImages() -> [ImageURL] {
        var images: [ImageURL] = []
        for _ in 0...10 {
            let imageURL = ImageURL(context: viewContext)
            imageURL.url = "www.google.com"
            images.append(imageURL)
        }
        return images
    }

    func generateQuestions(_ count: Int, _ level: Level, _ leitner: Leitner) -> [Question] {
        var questions: [Question] = []
        for index in 0 ..< count {
            let question = Question(context: viewContext)
            question.question = "Question \(index)"
            question.answer = "Answer with long text to test how it looks like on small screen we want to sure that the text is perfectly fit on the screen on smart phones and computers even with huge large screen \(index)"
            question.level = level
            question.passTime = level.level == 1 ? nil : Date().advanced(by: -(24 * 360))
            question.completed = Bool.random()
            question.favorite = Bool.random()
            question.createTime = Date()
            question.leitner = leitner

            questions.append(question)
        }
        return questions
    }
}

extension PersistenceController {
    @MainActor
    func dropDatabase(_ info: DropInfo) {
        info.itemProviders(for: [.fileURL, .data]).forEach { item in
            item.loadItem(forTypeIdentifier: item.registeredTypeIdentifiers.first!, options: nil) { data, error in
                do {
                    if let url = data as? URL,
                       let newFileLocation = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(url.lastPathComponent)
                    {
                        if FileManager.default.fileExists(atPath: newFileLocation.path) {
                            try FileManager.default.removeItem(atPath: newFileLocation.path)
                        }
                        let isAccessing = url.startAccessingSecurityScopedResource()
                        let fileData = try Data(contentsOf: url)
                        try fileData.write(to: newFileLocation)
                        PersistenceController.shared.replaceDatabase(appSuppportFile: newFileLocation)
                        if isAccessing {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                } catch {
                    print("error happend\(error.localizedDescription)")
                }
            }
        }
    }
}
