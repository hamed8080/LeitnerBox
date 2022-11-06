//
// AddTagsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct AddTagsView: View {
    @StateObject
    var question: Question

    @StateObject
    var viewModel: TagViewModel

    var completion: (() -> Void)?

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for tags...")

            List {
                ForEach(viewModel.filtered) { tag in
                    Label(tag.name ?? "", systemImage: "tag")
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.addToTag(tag, question)
                            completion?()
                            dismiss()
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.filtered)
            .listStyle(.plain)
        }
    }
}

struct AddTagsView_Previews: PreviewProvider {
    static var previews: some View {
        let leitner = LeitnerView_Previews.leitner
        let question = leitner.allQuestions.first!
        AddTagsView(question: question, viewModel: .init(viewContext: PersistenceController.shared.viewContext, leitner: leitner))
            .preferredColorScheme(.dark)
    }
}
