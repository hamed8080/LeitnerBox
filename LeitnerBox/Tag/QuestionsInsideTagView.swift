//
//  QuestionsInsideTagView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI

struct QuestionsInsideTagView: View {
    
    var tag:Tag
    
    var body: some View {
        ZStack{
            List {
                ForEach(tag.questions) { question in
                  row(question)
                }
            }
            .animation(.easeInOut, value: tag.questions)
            .listStyle(.plain)
        }
        .navigationTitle("\(tag.name ?? "")")
    }
    
    @ViewBuilder
    func row(_ question:Question)->some View{
        VStack(alignment:.leading,spacing: 8){
            Text(question.question ?? "")
                .font(.body)
            Text(question.answer ?? "")
                .font(.footnote)
                .foregroundColor(.gray)
            Text(question.detailDescription ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct QuestionsInsideTagView_Previews: PreviewProvider {
    
    static var previews: some View {
        QuestionsInsideTagView(tag: LeitnerView_Previews.leitner.tagsArray.first ?? Tag())
            .preferredColorScheme(.light)
    }
}
