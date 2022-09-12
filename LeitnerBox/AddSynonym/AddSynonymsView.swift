//
// AddSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/24/22.

import SwiftUI

struct AddSynonymsView: View {
    @ObservedObject
    var viewModel: SynonymViewModel

    @ObservedObject
    var searchVM: SearchViewModel

    init(viewModel: SynonymViewModel) {
        self.viewModel = viewModel
        self.searchVM = SearchViewModel(viewContext: viewModel.viewContext, leitner: viewModel.leitner)
    }

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for synonyms...")

            List {
                ForEach(viewModel.filtered) { question in
                    NormalQuestionRow(question: question, tagsViewModel: .init(viewContext: viewModel.viewContext, leitner: viewModel.leitner), searchViewModel: searchVM)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.addAsSynonym(question)
                            dismiss()
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.filtered)
            .listStyle(.plain)
        }
    }
}

struct AddSynonymsView_Previews: PreviewProvider {
    static var previews: some View {
        let firstQuestion = LeitnerView_Previews.leitner.allQuestions.first!
        let vm = SynonymViewModel(viewContext: PersistenceController.preview.container.viewContext, question: firstQuestion)
        AddSynonymsView(viewModel: vm)
            .onAppear {
                vm.searchText = "t"
            }
            .preferredColorScheme(.dark)
    }
}
