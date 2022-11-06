//
// ToolbarNavigation.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
import SwiftUI

struct ToolbarNavigation<Content: View>: View {
    let title: String
    let systemImageName: String
    let destination: () -> Content

    internal init(title: String, systemImageName: String, @ViewBuilder destination: @escaping () -> Content) {
        self.title = title
        self.systemImageName = systemImageName
        self.destination = destination
    }

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            ZStack {
                Text(title)
                    .frame(width: 0, height: 0)
                    .allowsHitTesting(false)
                    .disabled(true)
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .toobarNavgationButtonStyle()
            }
        }
    }
}

struct ToolbarNavigationModifire: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(.title3)
            .symbolRenderingMode(.palette)
            .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
    }
}

extension View {
    func toobarNavgationButtonStyle() -> some View {
        modifier(ToolbarNavigationModifire())
    }
}
