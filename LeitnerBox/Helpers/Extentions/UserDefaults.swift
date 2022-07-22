//
//  UserDefaults.swift
//  LeitnerBox
//
//  Created by hamed on 7/22/22.
//

import Foundation
extension UserDefaults{
    static let group = UserDefaults(suiteName: AppGroupLocalStorage.groupName)
}
