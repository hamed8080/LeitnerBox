//
// QuestionsInsideTagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import SwiftUI

struct QuestionsInsideTagView: View {
    var tag: Tag
    @StateObject var tagViewModel: TagViewModel
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice

    var body: some View {
        ZStack {
            List {
                ForEach(tag.questions) { question in
                    NormalQuestionRow(question: question, tagsViewModel: tagViewModel, aceessControls: AccessControls.normal + [.trailingControls, .microphone])
                        .environmentObject(SearchViewModel(viewContext: tagViewModel.viewContext, leitner: tagViewModel.leitner, voiceSpeech: voiceSpeech))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
            }
            .animation(.easeInOut, value: tag.questions)
            .listStyle(.plain)
        }
        .navigationTitle("\(tag.name ?? "")")
    }
}

struct QuestionsInsideTagView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        static let context = PersistenceController.shared.viewContext
        @StateObject var viewModel = TagViewModel(viewContext: context, leitner: Preview.leitner)

        var body: some View {
            QuestionsInsideTagView(tag: Preview.leitner.tagsArray.first ?? Tag(), tagViewModel: viewModel)
                .preferredColorScheme(.light)
        }
    }

    static var previews: some View {
        Preview()
    }
}
