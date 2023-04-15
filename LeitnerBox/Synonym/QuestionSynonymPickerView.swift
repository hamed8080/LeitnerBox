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
        ZStack(alignment: .top) {

            List {
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
            .safeAreaInset(edge: .top) {
                Spacer()
                    .frame(height: 48)
            }
            TopSheetTextEditorView(searchText: $objVM.synonymVM.searchText, placeholder: "Search for synonyms...")
                .background(
                    LinearGradient(colors: [.blue.opacity(0.2), .green.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .overlay (
                            Material.ultraThinMaterial
                        )
                )
        }
        .animation(.easeInOut, value: objVM.synonymVM.searchedQuestions.count)

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
