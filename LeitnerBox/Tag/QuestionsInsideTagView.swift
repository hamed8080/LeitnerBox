//
// QuestionsInsideTagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

struct QuestionsInsideTagView: View {
    var tag: Tag

    @StateObject
    var tagViewModel: TagViewModel

    var body: some View {
        ZStack {
            List {
                ForEach(tag.questions) { question in
                    NormalQuestionRow(question: question, tagsViewModel: tagViewModel, ac: AccessControls.normal + [.trailingControls, .microphone])
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
        static let leitner = LeitnerView_Previews.leitner
        static let context = PersistenceController.previewVC

        @StateObject
        var vm = TagViewModel(viewContext: context, leitner: leitner)

        var body: some View {
            QuestionsInsideTagView(tag: LeitnerView_Previews.leitner.tagsArray.first ?? Tag(), tagViewModel: vm)
                .preferredColorScheme(.light)
        }
    }
    static var previews: some View {
        Preview()
    }
}
