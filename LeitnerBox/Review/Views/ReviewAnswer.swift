//
//  ReviewAnswer.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct ReviewAnswer: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Tap to hide answer")
                    .foregroundColor(.accentColor)
                    .colorMultiply(.accentColor)
                    .font(.title2.weight(.medium))
                    .onTapGesture {
                        viewModel.toggleAnswer()
                    }

                Text(viewModel.selectedQuestion?.answer ?? "")
                    .font(sizeClass == .compact ? .title3.weight(.semibold) : .title2.weight(.medium))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .onTapGesture {
            viewModel.toggleAnswer()
        }
        .transition(.scale)
    }
}
