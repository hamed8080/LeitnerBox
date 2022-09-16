//
//  IconButtonModifire.swift
//  LeitnerBox
//
//  Created by hamed on 9/12/22.
//

import Foundation
import SwiftUI

struct IconButtonKeyboardShortcut: View {

    let title: String
    let systemImageName: String

    internal init(title: String, systemImageName: String) {
        self.title = title
        self.systemImageName = systemImageName
    }

    var body: some View {
        ZStack {
            Text(title)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
                .disabled(true)
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
        }
    }
}

struct ReviewIconStyle: ViewModifier {

    let accent: Bool

    func body(content: Content) -> some View {
        content
            .foregroundColor(accent ? .accentColor : .orange)
            .frame(width: 32, height: 32)
    }
}


extension View {
    func reviewIconStyle(accent: Bool = true) -> some View {
        modifier(ReviewIconStyle(accent: accent))
    }
}
