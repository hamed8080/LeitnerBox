//
//  DeleteDialog.swift
//  LeitnerBox
//
//  Created by hamed on 11/1/22.
//

import SwiftUI

struct DeleteDialog: View {
    @EnvironmentObject var viewModel: ReviewViewModel

    var body: some View {
        VStack {
            Text(attributedText(text: "Are you sure you want to delete \(viewModel.selectedQuestion?.question ?? "") question?", textRange: viewModel.selectedQuestion?.question ?? ""))

            Button {
                viewModel.showDelete.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)

            Button {
                viewModel.deleteQuestion()
            } label: {
                HStack {
                    Spacer()
                    Text("Delete")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .keyboardShortcut("d", modifiers: [.command])
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }

    func attributedText(text: String, textRange: String) -> AttributedString {
        var text = AttributedString(text)
        if let range = text.range(of: textRange) {
            text[range].foregroundColor = .purple
            text[range].font = .title2.bold()
        }
        return text
    }
}
