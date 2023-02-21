//
//  ReviewQuestion.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct ReviewQuestion: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    private var question: Question? { viewModel.selectedQuestion }

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 16) {
                Text(question?.question ?? "")
                    .multilineTextAlignment(.center)
                    .font(sizeClass == .compact ? .title2.weight(.semibold) : .largeTitle.weight(.bold))

                Text(question?.detailDescription ?? "")
                    .font(sizeClass == .compact ? .title3.weight(.semibold) : .title2.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("subtitleTextColor"))
                    .transition(.scale)
                if let partOfspeech = viewModel.partOfspeech {
                    Text(partOfspeech)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
            }
            Spacer()
        }
    }
}
