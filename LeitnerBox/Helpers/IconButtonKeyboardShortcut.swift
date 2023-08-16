//
// IconButtonKeyboardShortcut.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

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
            .frame(width: 22, height: 22)
            .padding()
            .cornerRadius(6)
            .background(Color.accentColor.opacity(0.09).cornerRadius(12))
            .foregroundColor(Color.accentColor)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 1)
            }
    }
}

extension View {
    func reviewIconStyle(accent: Bool = true) -> some View {
        modifier(ReviewIconStyle(accent: accent))
    }
}

struct ReviewReviewStyle_Previews: PreviewProvider {
    struct Preview: View {

        var body: some View {
            Button {

            } label: {
                IconButtonKeyboardShortcut(title: "", systemImageName: "star")
            }
            .reviewIconStyle()
        }
    }

    static var previews: some View {
        NavigationStack {
            HStack {
                Preview()
            }
            .frame(width: 64, height: 64)
        }
    }
}
