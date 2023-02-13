//
// AddSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct AddSynonymsView: View {
    @StateObject var viewModel: SynonymViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    var completion: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for synonyms...")

            List {
                ForEach(viewModel.searchedQuestions) { question in
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
            .animation(.easeInOut, value: viewModel.searchedQuestions)
            .listStyle(.plain)
        }
    }
}

struct AddSynonymsView_Previews: PreviewProvider {
    struct Preview: View {
        let context = PersistenceController.shared.viewContext
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        @StateObject var viewModel = SynonymViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)

        var body: some View {
            AddSynonymsView(viewModel: viewModel)
                .onAppear {
                    viewModel.searchText = "t"
                }
                .environmentObject(SearchViewModel(viewContext: context, leitner: Preview.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice))
                .environmentObject(LeitnerViewModel(viewContext: context))
                .environment(\.managedObjectContext, context)
                .preferredColorScheme(.dark)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
