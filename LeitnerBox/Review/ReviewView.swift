//
// ReviewView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @StateObject var viewModel: ReviewViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice
    @State var showTagPicker: Bool = false
    @State var showSynonymPicker: Bool = false

    var body: some View {
        if viewModel.isFinished {
            NotAnyToReviewView()
        } else if Level.hasAnyReviewable(context: context, level: viewModel.level, leitnerId: viewModel.leitner?.id ?? -1) {
            ZStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 48) {
                            ReviewHeader()
                                .environmentObject(viewModel)
                            ReviewQuestion()
                                .environmentObject(viewModel)
                            if let question = viewModel.selectedQuestion {
                                VStack(alignment: .leading, spacing: 12) {
                                    Button {
                                        showTagPicker.toggle()
                                    } label: {
                                        Label("Tags", systemImage: "plus.circle")
                                    }
                                    .keyboardShortcut("t", modifiers: [.command])
                                    .buttonStyle(.borderless)

                                    QuestionTagList(tags: question.tagsArray ?? []) { tag in
                                        objVM.tagVM.removeTagForQuestion(tag, question: viewModel.selectedQuestion)
                                    }

                                    Button {
                                        showSynonymPicker.toggle()
                                    } label: {
                                        Label("Synonyms", systemImage: "plus.circle")
                                    }
                                    .buttonStyle(.borderless)

                                    QuestionSynonymList(synonyms: viewModel.selectedQuestion?.synonymsArray ?? []) { _ in
                                        // Navigate to add or edit question
                                    } onLongClick: { _ in
//                                        synonymVM.removeSynonymFromQuestion(question: question, synonymQuestion: synonymQuestion)
                                    }
                                }
                            }
                            ReviewControls()
                                .environmentObject(viewModel)
                            if viewModel.isShowingAnswer {
                                ReviewAnswer()
                                    .environmentObject(viewModel)
                            } else {
                                TapToAnswerView()
                                    .environmentObject(viewModel)
                            }
                        }
                    }
                    Spacer()
                    PassOrFailButtons()
                        .environmentObject(viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.isShowingAnswer)
            .padding()
            .background(Color(named: "dialogBackground"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
                        AddOrEditQuestionView()
                            .environmentObject(objVM)
                    }
                    .keyboardShortcut("a", modifiers: [.command, .option])

                    ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
                        SearchView()
                            .environmentObject(objVM)
                    }
                    .keyboardShortcut("s", modifiers: [.command, .option])
                }
            }
            .customDialog(isShowing: $viewModel.showDelete) {
                DeleteDialog()
                    .environmentObject(viewModel)
            }
            .onDisappear {
                viewModel.stopPronounce()
            }
            .sheet(isPresented: $showSynonymPicker) {
                QuestionSynonymPickerView { question in
                    guard let baseQuestion = viewModel.selectedQuestion else { return }
                    objVM.synonymVM.addSynonymToQuestion(baseQuestion, question)
                }
                .environmentObject(objVM)
            }
            .sheet(isPresented: $showTagPicker) {
                TagsListPickerView { tag in
                    objVM.tagVM.addTagToQuestion(tag, question: viewModel.selectedQuestion)
                }
            }

        } else {
            NotAnyToReviewView()
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        static let level = (leitner.levels).filter { $0.level == 1 }.first
        @StateObject var viewModel = ReviewViewModel(viewContext: PersistenceController.shared.viewContext, levelValue: 1, leitnerId: 1, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        var body: some View {
            ReviewView(viewModel: viewModel)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
