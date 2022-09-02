//
// UserDefaults.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation
extension UserDefaults {
    static let group = UserDefaults(suiteName: AppGroupLocalStorage.groupName)
}
