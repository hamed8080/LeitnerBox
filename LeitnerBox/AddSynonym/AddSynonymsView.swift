//
// AddSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct AddSynonymsView: View {
    @StateObject
    var viewModel: SynonymViewModel

    @Environment(\.dismiss)
    var dismiss

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var completion: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for synonyms...")

            List {
                ForEach(viewModel.filtered) { question in
                    NormalQuestionRow(question: question, tagsViewModel: .init(viewContext: context, leitner: viewModel.leitner))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.addAsSynonym(question)
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

struct AddSynonymsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject
        var viewModel = SynonymViewModel(viewContext: PersistenceController.shared.viewContext, question: LeitnerView_Previews.leitner.allQuestions.first!)

        var body: some View {
            AddSynonymsView(viewModel: viewModel)
                .onAppear {
                    viewModel.searchText = "t"
                }
                .environmentObject(SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: LeitnerView_Previews.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice))
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .preferredColorScheme(.dark)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
