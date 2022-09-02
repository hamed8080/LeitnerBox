//
// QuestionTagsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

struct QuestionTagsView: View {
    @ObservedObject
    var question: Question

    @State
    private var showAddTags = false

    let viewModel: TagViewModel

    var addPadding = false

    var accessControls: [AccessControls] = [.showTags, .addTag]

    var tagCompletion: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            if accessControls.contains(.addTag) {
                Button {
                    showAddTags.toggle()
                } label: {
                    Label("Tags", systemImage: "plus.circle")
                }
                .buttonStyle(.borderless)
                .padding(addPadding ? [.leading, .trailing] : [])
            }

            if accessControls.contains(.showTags) {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        let tags = question.tagsArray ?? []
                        ForEach(tags) { tag in
                            Text("\(tag.name ?? "")")
                                .foregroundColor(((tag.color as? UIColor)?.isLight() ?? false) ? .black : .white)
                                .font(.footnote.weight(.semibold))
                                .padding([.top, .bottom], 4)
                                .padding([.trailing, .leading], 8)
                                .background(
                                    tag.tagSwiftUIColor ?? .gray
                                )
                                .cornerRadius(6)
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                                .onTapGesture {} // do not remove this line it'll stop scrolling
                                .onLongPressGesture {
                                    if accessControls.contains(.removeTag) {
                                        viewModel.deleteTagFromQuestion(tag, question)
                                        tagCompletion?()
                                    }
                                }
                        }
                    }
                    .padding(addPadding ? [.leading, .trailing] : [])
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showAddTags, onDismiss: nil, content: {
            if let leitner = viewModel.leitner {
                AddTagsView(question: question, viewModel: .init(viewContext: viewModel.viewContext, leitner: leitner)) {
                    tagCompletion?()
                }
            }
        })
    }
}

struct QuestionTagsView_Previews: PreviewProvider {
    static var previews: some View {
        let leitner = LeitnerView_Previews.leitner
        let question = leitner.allQuestions.first!
        QuestionTagsView(question: question, viewModel: .init(viewContext: PersistenceController.previewVC, leitner: leitner))
    }
}
