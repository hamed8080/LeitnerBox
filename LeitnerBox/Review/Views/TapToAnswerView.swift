//
//  TapToAnswerView.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

/// Animation causes multiple resest in review, it's better stay separate from other views.
struct TapToAnswerView: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    @State private var isAnimationShowAnswer = false

    var body: some View {
        Button {
            viewModel.toggleAnswer()
        } label: {
            Text("Tap to show answer")
                .foregroundColor(.accentColor)
                .colorMultiply(isAnimationShowAnswer ? .accentColor : .accentColor.opacity(0.5))
                .font(.title2.weight(.medium))
        }
        .keyboardShortcut("v", modifiers: [.command])
        .scaleEffect(isAnimationShowAnswer ? 1.05 : 1)
        .rotation3DEffect(.degrees(isAnimationShowAnswer ? 0 : 90), axis: (x: 100, y: 1, z: 0), anchor: .leading, anchorZ: 10)
        .animation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: isAnimationShowAnswer)
        .onAppear {
            isAnimationShowAnswer = true
        }
        .onDisappear {
            isAnimationShowAnswer = false
        }
    }
}
