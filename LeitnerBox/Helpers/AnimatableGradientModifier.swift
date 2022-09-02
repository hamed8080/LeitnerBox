//
// AnimatableGradientModifier.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import Foundation
import SwiftUI

struct AnimatableGradientModifier: ViewModifier, Animatable {
    var from: [UIColor]
    var to: [UIColor]
    var progress: CGFloat = 0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content _: Content) -> some View {
        var gColors = [Color]()
        for i in 0 ..< from.count {
            gColors.append(colorMixer(c1: from[i], c2: to[i], progress: progress))
        }
        return LinearGradient(gradient: Gradient(colors: gColors),
                              startPoint: UnitPoint(x: 0, y: 0),
                              endPoint: UnitPoint(x: 1, y: 1))
    }

    func colorMixer(c1: UIColor, c2: UIColor, progress: CGFloat) -> Color {
        guard let cc1 = c1.cgColor.components else { return Color(c1) }
        guard let cc2 = c2.cgColor.components else { return Color(c1) }

        let r = (cc1[0] + (cc2[0] - cc1[0]) * progress)
        let g = (cc1[1] + (cc2[1] - cc1[1]) * progress)
        let b = (cc1[2] + (cc2[2] - cc1[2]) * progress)

        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}

extension View {
    func animatableGradient(from: [UIColor], to: [UIColor], progress: CGFloat) -> some View {
        modifier(AnimatableGradientModifier(from: from, to: to, progress: progress))
    }
}
