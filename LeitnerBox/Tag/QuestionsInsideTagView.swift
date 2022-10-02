//
// QuestionsInsideTagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

struct QuestionsInsideTagView: View {
    var tag: Tag

    @ObservedObject
    var tagViewModel: TagViewModel

    /// It'll prevent the searchVM create multiple times
    @ObservedObject
    var serachVM: SearchViewModel

    init(tag: Tag, tagViewModel: TagViewModel) {
        self.tag = tag
        self.tagViewModel = tagViewModel
        serachVM = SearchViewModel(viewContext: tagViewModel.viewContext, leitner: tagViewModel.leitner)
    }

    var body: some View {
        ZStack {
            List {
                ForEach(tag.questions) { question in
                    NormalQuestionRow(question: question, tagsViewModel: tagViewModel, searchViewModel: serachVM, accessControls: AccessControls.normal + [.trailingControls, .microphone])
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
    static var previews: some View {
        let leitner = LeitnerView_Previews.leitner
        let vm = TagViewModel(viewContext: PersistenceController.previewVC, leitner: leitner)
        QuestionsInsideTagView(tag: LeitnerView_Previews.leitner.tagsArray.first ?? Tag(), tagViewModel: vm)
            .preferredColorScheme(.light)
    }
}
