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
    private var question: Question? { viewModel.selectedQuestion }
    private var tags: [Tag] { question?.tagsArray ?? [] }
    private var synonyms: [Question] { question?.synonymsArray ?? [] }

    var body: some View {
        if viewModel.isFinished {
            NotAnyToReviewView()
        } else if Level.hasAnyReviewable(context: context, level: viewModel.level, leitnerId: viewModel.leitner?.id ?? -1) {
            ZStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 48) {
                            ReviewHeader()
                            ReviewQuestion()
                            if let question = question {
                                VStack(alignment: .leading, spacing: 12) {
                                    Button {
                                        showTagPicker.toggle()
                                    } label: {
                                        Label("Tags", systemImage: "plus.circle")
                                    }
                                    .keyboardShortcut("t", modifiers: [.command])
                                    .buttonStyle(.borderless)

                                    QuestionTagList(tags: tags) { tag in
                                        objVM.tagVM.removeTagForQuestion(tag, question: question)
                                    }

                                    Button {
                                        showSynonymPicker.toggle()
                                    } label: {
                                        Label("Synonyms", systemImage: "plus.circle")
                                    }
                                    .buttonStyle(.borderless)

                                    QuestionSynonymList(synonyms: synonyms) { _ in
                                        // Navigate to add or edit question
                                    } onLongClick: { synonymQuestion in
                                        objVM.synonymVM.removeQuestionFromSynonym(synonymQuestion)
                                    }
                                }
                            }
                            if viewModel.isShowingAnswer {
                                ReviewAnswer()
                            } else {
                                TapToAnswerView()
                            }
                        }
                    }
                    Spacer()
                    PassOrFailButtons()
                }
            }
            .environmentObject(viewModel)
            .animation(.easeInOut, value: tags.count)
            .animation(.easeInOut, value: synonyms.count)
            .animation(.easeInOut, value: viewModel.isShowingAnswer)
            .padding()
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
                    guard let baseQuestion = self.question else { return }
                    objVM.synonymVM.addSynonymToQuestion(baseQuestion, question)
                }
                .environmentObject(objVM)
            }
            .sheet(isPresented: $showTagPicker) {
                TagsListPickerView { tag in
                    objVM.tagVM.addTagToQuestion(tag, question: question)
                }
            }

        } else {
            NotAnyToReviewView()
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        static let level = (leitner.levels).filter { $0.level == 1 }.first
        static let context = PersistenceController.shared.viewContext
        @StateObject var leitnerVM = LeitnerViewModel(viewContext: context)
        @StateObject var viewModel = ReviewViewModel(viewContext: context,
                                                     levelValue: 1, leitnerId: 1, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)

        var body: some View {
            ReviewView(viewModel: viewModel)
                .environment(\.managedObjectContext, Preview.context)
                .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
                .environmentObject(ObjectsContainer(context: Preview.context, leitner: Preview.leitner, leitnerVM: leitnerVM))
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
