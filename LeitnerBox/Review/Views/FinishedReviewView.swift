//
//  FinishedReviewView.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct FinishedReviewView: View {
    @State
    private var isAnimating = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64, alignment: .center)
                .foregroundStyle(.white, Color("green_light"))
                .scaleEffect(isAnimating ? 1 : 0.8)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color("green_light").opacity(0.5), lineWidth: 16)
                        .scaleEffect(isAnimating ? 1.1 : 0.8)
                )
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        isAnimating = true
                    }
                }

            Text("There is nothing to review here at the moment.")
                .font(.body.weight(.medium))
                .foregroundColor(.gray)
        }
        .frame(height: 96)
    }
}
