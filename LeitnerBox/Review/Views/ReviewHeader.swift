//
//  ReviewHeader.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct ReviewHeader: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        if sizeClass == .regular {
            ipadHeader
        } else {
            headers
        }
    }

    var headers: some View {
        VStack {
            Text(verbatim: "Level: \(viewModel.level.level)")
                .font(.title.weight(.semibold))
                .padding(.bottom)
                .foregroundColor(.accentColor)
            Text("Total: \(viewModel.passCount + viewModel.failedCount) / \(viewModel.totalCount), Passed: \(viewModel.passCount), Failed: \(viewModel.failedCount)".uppercased())
                .font(sizeClass == .compact ? .body.bold() : .title3.bold())
        }
    }

    var ipadHeader: some View {
        HStack {
            LinearGradient(colors: [.mint.opacity(0.8), .mint.opacity(0.5), .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom).mask {
                Text(verbatim: "\(viewModel.passCount)")
                    .fontWeight(.semibold)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
            }

            Spacer()
            Text("Total: \(viewModel.totalCount)".uppercased())
                .font(sizeClass == .compact ? .body.bold() : .title3.bold())
            Spacer()
            LinearGradient(colors: [.yellow.opacity(0.8), .yellow.opacity(0.5), .orange.opacity(0.3)], startPoint: .top, endPoint: .bottom).mask {
                Text(verbatim: "\(viewModel.failedCount)")
                    .fontWeight(.semibold)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
            }
        }
        .frame(height: 128)
        .padding([.leading, .trailing], 64)
    }
}
