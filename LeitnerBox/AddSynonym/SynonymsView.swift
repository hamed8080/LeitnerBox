//
// SynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct SynonymsView: View {
    @StateObject
    var viewModel: SynonymViewModel
    var accessControls: [AccessControls] = [.showSynonyms, .removeSynonym]

    var body: some View {
        List(viewModel.allSynonymsInLeitner) { synonym in

            VStack(alignment: .leading) {
                let firstQuestion = synonym.allQuestions.first
                Text(firstQuestion?.question ?? "")
                    .font(.title3.bold())

                let allQuestions = synonym.allQuestions.filter { $0 != firstQuestion }
                ScrollView(.horizontal) {
                    HStack(spacing: 4) {
                        ForEach(allQuestions) { question in
                            Text("\(String(question.question?.split(separator: "\n").first ?? ""))")
                                .foregroundColor(.accentColor)
                                .font(.footnote.weight(.semibold))
                                .padding([.top, .bottom], 4)
                                .padding([.trailing, .leading], 8)
                                .background(.blue.opacity(0.3))
                                .cornerRadius(6)
                                .transition(.asymmetric(insertion: .slide, removal: .scale))
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                                .onLongPressGesture {
                                    if accessControls.contains(.removeSynonym) {
                                        viewModel.deleteFromSynonym(question)
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Synonyms")
        .listStyle(.plain)
    }
}

struct SynonymsView_Previews: PreviewProvider {
    struct Preview: View {
        var body: some View {
            SynonymsView(viewModel: .init(viewContext: PersistenceController.shared.viewContext, question: LeitnerView_Previews.leitner.allQuestions.first!))
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
