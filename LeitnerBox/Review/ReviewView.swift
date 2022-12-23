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
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice

    var body: some View {
        if viewModel.isFinished {
            NotAnyToReviewView()
        } else if viewModel.level.hasAnyReviewable {
            ZStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 48) {
                            ReviewHeader(viewModel: viewModel)
                            ReviewQuestion(viewModel: viewModel)
                            if let question = viewModel.selectedQuestion {
                                VStack(alignment: .leading, spacing: 4) {
                                    QuestionTagsView(
                                        viewModel: .init(viewContext: context, leitner: viewModel.level.leitner!),
                                        accessControls: [.addTag, .showTags, .removeTag, .saveDirectly]
                                    )
                                    .environmentObject(question)
                                    QuestionSynonymsView(accessControls: [.addSynonym, .showSynonyms, .removeSynonym, .saveDirectly])
                                        .environmentObject(SynonymViewModel(viewContext: context, question: question))
                                }
                            }
                            ReviewControls(viewModel: viewModel)
                            if viewModel.isShowingAnswer {
                                ReviewAnswer(viewModel: viewModel)
                            } else {
                                TapToAnswerView(viewModel: viewModel)
                            }
                        }
                    }
                    Spacer()
                    PassOrFailButtons(viewModel: viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.isShowingAnswer)
            .padding()
            .background(Color(named: "dialogBackground"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
                        LazyView(AddOrEditQuestionView(viewModel: .init(viewContext: context, leitner: viewModel.level.leitner!)))
                    }
                    .keyboardShortcut("a", modifiers: [.command, .option])

                    if let leitner = viewModel.level.leitner {
                        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
                            SearchView()
                                .environmentObject(SearchViewModel(viewContext: context, leitner: leitner, voiceSpeech: voiceSpeech))
                        }
                        .keyboardShortcut("s", modifiers: [.command, .option])
                    }
                }
            }
            .customDialog(isShowing: $viewModel.showDelete, content: {
                DeleteDialog(viewModel: viewModel)
            })
            .onDisappear {
                viewModel.stopPronounce()
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
        @StateObject var viewModel = ReviewViewModel(viewContext: PersistenceController.shared.viewContext, level: level!, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
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
