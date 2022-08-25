//
//  QuestionTagsView.swift
//  LeitnerBox
//
//  Created by hamed on 6/4/22.
//

import SwiftUI

struct QuestionTagsView: View {

    @ObservedObject
    var question: Question

    @State
    private var showAddTags = false

    var showAddButton = true

    let viewModel: TagViewModel

    var addPadding = false

    var tagCompletion:(()->())? = nil
    
    var body: some View {
        VStack(alignment: .leading){
            if showAddButton {
                Button {
                    showAddTags.toggle()
                } label: {
                    Label("Tags", systemImage: "plus.circle")
                }
                .buttonStyle(.borderless)
                .padding(addPadding ? [.leading, .trailing] : [])
            }

            ScrollView(.horizontal){
                HStack(spacing:12){
                    let tags = question.tagsArray ?? []
                    ForEach(tags) { tag in
                        Text("\(tag.name ?? "")")
                            .foregroundColor( ((tag.color as? UIColor)?.isLight() ?? false) ? .black : .white)
                            .font(.footnote.weight(.semibold))
                            .padding([.top, .bottom], 4)
                            .padding([.trailing, .leading], 8)
                            .background(
                                (tag.tagSwiftUIColor ?? .gray)
                            )
                            .cornerRadius(6)
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                            .onTapGesture {  } //do not remove this line it'll stop scrolling
                            .onLongPressGesture {
                                viewModel.deleteTagFromQuestion(tag, question)
                                tagCompletion?()
                            }
                    }
                }
                .padding(addPadding ? [.leading, .trailing] : [])
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showAddTags, onDismiss: nil, content: {
            if let leitner = viewModel.leitner{
                AddTagsView(question: question, viewModel: .init(viewContext: viewModel.viewContext, leitner: leitner)){
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
