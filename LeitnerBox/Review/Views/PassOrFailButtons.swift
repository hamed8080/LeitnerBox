//
//  PassOrFailButtons.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct PassOrFailButtons: View {
    @StateObject var viewModel: ReviewViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        HStack(spacing: sizeClass == .regular ? 48 : 8) {
            Button {
                withAnimation {
                    viewModel.pass()
                }
            } label: {
                HStack {
                    Spacer()
                    Label("PASS", systemImage: "checkmark.circle.fill")
                    Spacer()
                }
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.accentColor)

            Button {
                withAnimation {
                    viewModel.fail()
                }
            } label: {
                HStack {
                    Spacer()
                    Label("FAIL", systemImage: "xmark.circle.fill")
                    Spacer()
                }
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.red)
        }
        .padding([.leading, .trailing])
    }
}
