//
//  ReviewQuestion.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct ReviewQuestion: View {
    @StateObject
    var viewModel: ReviewViewModel

    @Environment(\.horizontalSizeClass)
    var sizeClass

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 16) {
                Text(viewModel.selectedQuestion?.question ?? "")
                    .multilineTextAlignment(.center)
                    .font(sizeClass == .compact ? .title2.weight(.semibold) : .largeTitle.weight(.bold))

                Text(viewModel.selectedQuestion?.detailDescription ?? "")
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
