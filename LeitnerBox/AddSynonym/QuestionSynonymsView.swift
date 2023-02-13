//
// QuestionSynonymsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct QuestionSynonymsView: View {
    @EnvironmentObject var viewModel: SynonymViewModel
    var accessControls: [AccessControls] = [.showSynonyms, .addSynonym]
    @State var showAddSynonyms = false
    @State private var selectedQuestion: Question?
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

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
                    let question = viewModel.baseQuestion
                    let allSynonymsQuestions = Synonym.allSynonyms(context: context, question: question?.question ?? "")
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
                                            saveDirectlyIfHasAccess()
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
            if let selectedQuestion = selectedQuestion {
                AddOrEditQuestionView(viewModel: .init(viewContext: context, leitner: viewModel.leitner, question: selectedQuestion))
            }
        }
        .sheet(isPresented: $showAddSynonyms, onDismiss: nil, content: {
            AddSynonymsView(viewModel: viewModel) {
                saveDirectlyIfHasAccess()
            }
        })
    }

    func saveDirectlyIfHasAccess() {
        if accessControls.contains(.saveDirectly) {
            withAnimation {
                PersistenceController.saveDB(viewContext: context)
            }
        }
    }
}
