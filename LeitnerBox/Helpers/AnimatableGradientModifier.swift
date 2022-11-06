//
// AnimatableGradientModifier.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
import SwiftUI

struct AnimatableGradientModifier: ViewModifier, Animatable {
    var from: [UIColor]
    var toColor: [UIColor]
    var progress: CGFloat = 0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content _: Content) -> some View {
        var gColors = [Color]()
        for index in 0 ..< from.count {
            gColors.append(colorMixer(color1: from[index], color2: toColor[index], progress: progress))
        }
        return LinearGradient(gradient: Gradient(colors: gColors),
                              startPoint: UnitPoint(x: 0, y: 0),
                              endPoint: UnitPoint(x: 1, y: 1))
    }

    func colorMixer(color1: UIColor, color2: UIColor, progress: CGFloat) -> Color {
        guard let cc1 = color1.cgColor.components else { return Color(color1) }
        guard let cc2 = color2.cgColor.components else { return Color(color1) }

        let red = (cc1[0] + (cc2[0] - cc1[0]) * progress)
        let green = (cc1[1] + (cc2[1] - cc1[1]) * progress)
        let blue = (cc1[2] + (cc2[2] - cc1[2]) * progress)

        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension View {
    func animatableGradient(from: [UIColor], toColor: [UIColor], progress: CGFloat) -> some View {
        modifier(AnimatableGradientModifier(from: from, toColor: toColor, progress: progress))
    }
}
