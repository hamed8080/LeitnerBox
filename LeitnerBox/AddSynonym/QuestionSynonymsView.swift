//
// QuestionSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import SwiftUI

struct QuestionSynonymsView: View {
    @ObservedObject
    var viewModel: SynonymViewModel

    var accessControls: [AccessControls] = [.showSynonyms, .addSynonym]

    @State
    var showAddSynonyms = false

    @State
    private var selectedQuestion: Question? = nil

    var body: some View {
        VStack(alignment: .leading) {
            if accessControls.contains(.addSynonym) {
                Button {
                    showAddSynonyms.toggle()
                } label: {
                    Label("Synonyms", systemImage: "plus.circle")
                }
                .keyboardShortcut("s", modifiers: [.command])
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
                navigateToEditQuestion
            }
        }
        .sheet(isPresented: $showAddSynonyms, onDismiss: nil, content: {
            AddSynonymsView(viewModel: viewModel)
        })
    }

    @ViewBuilder
    var navigateToEditQuestion: some View {
        let binding = Binding(
            get: { selectedQuestion != nil },
            set: { _ in }
        )

        if let selectedQuestion = selectedQuestion {
            NavigationLink(isActive: binding) {
                let level = selectedQuestion.level ?? viewModel.leitner.firstLevel
                AddOrEditQuestionView(vm: .init(viewContext: viewModel.viewContext, level: level!, question: selectedQuestion, isInEditMode: true))
                    .onDisappear {
                        self.selectedQuestion = nil
                    }
            } label: {
                EmptyView()
                    .frame(width: 0, height: 0)
            }
            .hidden()
        }
    }
}
