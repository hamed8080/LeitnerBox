//
// AppGroupLocalStorage.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation

final class AppGroupLocalStorage {
    static let groupName = "group.ir.app_group"
    static let shared = AppGroupLocalStorage()

    func saveFile(fileURL: URL, result: (Error?) -> Void) {
        let data = try? Data(contentsOf: fileURL)
        let fileManager = FileManager.default

        try? fileManager.createDirectory(at: fileManager.appGroupDBFolder!, withIntermediateDirectories: true, attributes: nil)
        guard let newFilePath = fileManager.appGroupDBFolder?.appendingPathComponent(fileURL.lastPathComponent, isDirectory: false) else { return }
        do {
            try data?.write(to: newFilePath)
            result(nil)
        } catch {
            result(error)
        }
    }
}
