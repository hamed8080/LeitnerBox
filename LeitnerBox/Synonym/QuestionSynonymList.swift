//
//  QuestionSynonymList.swift
//  LeitnerBox
//
//  Created by hamed on 2/15/23.
//

import SwiftUI

struct QuestionSynonymList: View {
    var synonyms: [Question]
    var onClick: (Question) -> Void
    var onLongClick: (Question) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(synonyms) { question in
                    Text("\(String(question.question?.split(separator: "\n").first ?? ""))")
                        .foregroundColor(.accentColor)
                        .font(.footnote.weight(.semibold))
                        .padding([.top, .bottom], 4)
                        .padding([.trailing, .leading], 8)
                        .background(.blue.opacity(0.3))
                        .cornerRadius(6)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                        .onTapGesture {
                            onClick(question)
                        } // do not remove this line, it'll stop scrolling
                        .onLongPressGesture {
                            onLongClick(question)
                        }
                }
                .padding([.bottom])
            }
        }
    }
}

struct QuestionSynonymList_Previews: PreviewProvider {
    static var previews: some View {
        QuestionSynonymList(synonyms: []) { _ in
        } onLongClick: { _ in
        }
    }
}
