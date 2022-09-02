//
// AppGroupLocalStorage.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation

class AppGroupLocalStorage {
    static let groupName = "group.ir.app_group"
    static let shared = AppGroupLocalStorage()

    func saveFile(fileURL: URL, result: (Error?) -> Void) {
        let data = try? Data(contentsOf: fileURL)
        let fm = FileManager.default

        try? fm.createDirectory(at: fm.appGroupDBFolder!, withIntermediateDirectories: true, attributes: nil)
        guard let newFilePath = fm.appGroupDBFolder?.appendingPathComponent(fileURL.lastPathComponent, isDirectory: false) else { return }
        do {
            try data?.write(to: newFilePath)
            result(nil)
        } catch {
            result(error)
        }
    }
}
