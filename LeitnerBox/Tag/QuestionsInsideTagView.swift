//
// QuestionsInsideTagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import SwiftUI

struct QuestionsInsideTagView: View {
    var tag: Tag
    @FetchRequest var fetchRequest: FetchedResults<Question>
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice

    var body: some View {
        ZStack {
            List {
                ForEach(fetchRequest) { question in
                    NormalQuestionRow(question: question)
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
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        static let context = PersistenceController.shared.viewContext
        @StateObject var viewModel = TagViewModel(viewContext: context, leitner: Preview.leitner)
        static let tag = Preview.leitner.tagsArray.first ?? Tag()
        var body: some View {
            QuestionsInsideTagView(tag: Preview.tag,
                                   fetchRequest: FetchRequest(sortDescriptors: [.init(\.question)], predicate: NSPredicate(format: "ANY tag.name == %@", Preview.tag.name ?? ""), animation: .easeInOut))
                .preferredColorScheme(.light)
        }
    }

    static var previews: some View {
        Preview()
    }
}
