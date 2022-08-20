//
//  QuestionsInsideTagView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI

struct QuestionsInsideTagView: View {
    
    var tag:Tag

    @ObservedObject
    var tagViewModel:TagViewModel

    var body: some View {
        ZStack{
            List {
                ForEach(tag.questions) { question in
                    NormalQuestionRow(question: question, tagsViewModel: tagViewModel)
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
        let leitner  = LeitnerView_Previews.leitner
        let vm = TagViewModel(viewContext: PersistenceController.previewVC, leitner: leitner)
        QuestionsInsideTagView(tag: LeitnerView_Previews.leitner.tagsArray.first ?? Tag(), tagViewModel: vm)
            .preferredColorScheme(.light)
    }
}
