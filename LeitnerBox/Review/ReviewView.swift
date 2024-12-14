//
// ReviewView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct ReviewView: View {
    @StateObject var viewModel: ReviewViewModel
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    private var question: Question? { viewModel.selectedQuestion }

    var body: some View {
        if viewModel.isFinished {
            NotAnyToReviewView()
        } else {
            ZStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 48) {
                            ReviewHeader()
                            ReviewQuestion()
                            if let question = question {
                                ReviewSheetButtonsMutableView(question: question)
                            }
                            if viewModel.isShowingAnswer {
                                ReviewAnswer()
                            } else {
                                TapToAnswerView()
                            }
                            
                            if let question = viewModel.selectedQuestion {
                                DownloadAndPlayButton(question: question)
                            }
                            
                            if question?.imagesArray?.isEmpty == false {
                                QuestionImagesView(isInReviewView: true)
                                    .environmentObject(QuestionViewModel(viewContext: context, leitner: question?.leitner ?? .init(), question: question))
                            }
                            
                            
                            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) {
                                if question?.location != nil {
                                    QuestionLocationView(isInReviewView: true)
                                        .environmentObject(QuestionViewModel(viewContext: context, leitner: question?.leitner ?? .init(), question: question))
                                }
                            }
                        }
                    }
                    Spacer()
                    ReviewControls()
                }
            }
            .environmentObject(viewModel)
            .animation(.easeInOut, value: viewModel.isShowingAnswer)
            .padding([.leading, .trailing])
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ReviewMutableToolbarView()
                }
            }
            .customDialog(isShowing: $viewModel.showDelete) {
                DeleteDialog()
                    .environmentObject(viewModel)
            }
            .onDisappear {
                viewModel.stopPronounce()
            }
        }
    }
}

struct ReviewMutableToolbarView: View {
    @EnvironmentObject var container: ObjectsContainer

    var body: some View {
        ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
            AddOrEditQuestionView()
                .environmentObject(container)
        }
        .keyboardShortcut("a", modifiers: [.command, .option])

        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
            SearchView(container: container)
                .environmentObject(container.searchVM)
        }
        .keyboardShortcut("s", modifiers: [.command, .option])
    }
}

struct ReviewSheetButtonsMutableView: View {
    let question: Question
    @EnvironmentObject var objVM: ObjectsContainer
    @State var showTagPicker: Bool = false
    @State var showSynonymPicker: Bool = false
    private var tags: [Tag] { question.tagsArray ?? [] }
    private var synonyms: [Question] { question.synonymsArray ?? [] }

    var body: some View {
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
        .animation(.easeInOut, value: tags.count)
        .animation(.easeInOut, value: synonyms.count)
        .sheet(isPresented: $showSynonymPicker) {
            QuestionSynonymPickerView { question in
                objVM.synonymVM.addSynonymToQuestion(self.question, question)
            }
            .environmentObject(objVM)
        }
        .sheet(isPresented: $showTagPicker) {
            TagsListPickerView { tag in
                objVM.tagVM.addTagToQuestion(tag, question: question)
            }
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
