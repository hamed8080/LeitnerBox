//
// ColorEx.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation
import SwiftUI

extension Color {
    init(named: String) {
        self = Color(UIColor(named: named)!)
    }

    static var random: Color {
        Color(uiColor: UIColor.random())
    }
}
