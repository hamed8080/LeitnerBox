//
// QuestionSynonymPickerView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct QuestionSynonymPickerView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    var completion: (Question) -> Void

    var body: some View {
        List {
            TopSheetTextEditorView(searchText: $objVM.synonymVM.searchText, placeholder: "Search for synonyms...")
                .listRowSeparator(.hidden)
            ForEach(objVM.synonymVM.searchedQuestions) { question in
                NormalQuestionRow(question: question)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        completion(question)
                        dismiss()
                    }
            }
        }
        .listStyle(.plain)
        .onDisappear {
            objVM.synonymVM.reset()
        }
    }
}

struct QuestionPickerView_Previews: PreviewProvider {
    struct Preview: View {
        let context = PersistenceController.shared.viewContext
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        @StateObject var viewModel = SynonymViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)

        var body: some View {
            QuestionSynonymPickerView { _ in }
                .environmentObject(viewModel)
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
