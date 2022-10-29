//
// AddSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

struct AddSynonymsView: View {
    @StateObject
    var viewModel: SynonymViewModel

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for synonyms...")

            List {
                ForEach(viewModel.filtered) { question in
                    NormalQuestionRow(question: question, tagsViewModel: .init(viewContext: viewModel.viewContext, leitner: viewModel.leitner))
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

    struct Preview: View {
        @StateObject
        var vm = SynonymViewModel(viewContext: PersistenceController.previewVC, question: LeitnerView_Previews.leitner.allQuestions.first!)

        var body: some View {
            AddSynonymsView(viewModel: vm)
                .onAppear {
                    vm.searchText = "t"
                }
                .environmentObject(SearchViewModel(viewContext: PersistenceController.previewVC, leitner: LeitnerView_Previews.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice))
                .environment(\.managedObjectContext, PersistenceController.previewVC)
                .preferredColorScheme(.dark)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
