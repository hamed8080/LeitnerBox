//
//  BoolEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/27/22.
//

import SwiftUI

extension Bool{
    static var iOS: Bool {
        guard #available(iOS 15, *) else {
            return true
        }
        // It's macOS
        return false
    }
}
