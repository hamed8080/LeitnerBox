//
// QuestionSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI
import CoreData

struct QuestionSynonymsView: View {
    @StateObject
    var viewModel: SynonymViewModel

    var accessControls: [AccessControls] = [.showSynonyms, .addSynonym]

    @State
    var showAddSynonyms = false

    @State
    private var selectedQuestion: Question? = nil

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if accessControls.contains(.addSynonym) {
                    Button {
                        showAddSynonyms.toggle()
                    } label: {
                        Label("Synonyms", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderless)
                }
                if accessControls.contains(.showSynonyms) {
                    let synonym = viewModel.baseQuestion.synonymsArray ?? []
                    let allSynonymsQuestions = (synonym.first?.allQuestions ?? []).filter { $0.objectID != viewModel.baseQuestion.objectID }
                    ScrollView(.horizontal) {
                        HStack(spacing: 4) {
                            ForEach(allSynonymsQuestions) { question in
                                Text("\(String(question.question?.split(separator: "\n").first ?? ""))")
                                    .foregroundColor(.accentColor)
                                    .font(.footnote.weight(.semibold))
                                    .padding([.top, .bottom], 4)
                                    .padding([.trailing, .leading], 8)
                                    .background(.blue.opacity(0.3))
                                    .cornerRadius(6)
                                    .transition(.asymmetric(insertion: .slide, removal: .scale))
                                    .onTapGesture {
                                        selectedQuestion = question
                                    } // do not remove this line, it'll stop scrolling
                                    .onLongPressGesture {
                                        if accessControls.contains(.removeSynonym) {
                                            viewModel.deleteFromSynonym(question)
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                            }
                        }
                        .padding([.bottom])
                    }
                    Spacer()
                }
            }
        }
        .navigationDestination(isPresented: Binding(get: { selectedQuestion != nil }, set: { _ in })) {
            let level = selectedQuestion?.level ?? viewModel.leitner.firstLevel
            if let selectedQuestion {
                AddOrEditQuestionView(
                    vm: .init(viewContext: context, level: level!, question: selectedQuestion, isInEditMode: true),
                    synonymsVM: SynonymViewModel(viewContext: context, question: selectedQuestion),
                    tagVM: TagViewModel(viewContext: context, leitner: level!.leitner!)
                )
            }
        }
        .sheet(isPresented: $showAddSynonyms, onDismiss: nil, content: {
            AddSynonymsView(viewModel: viewModel)
        })
    }
}
