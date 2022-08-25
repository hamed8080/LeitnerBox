//
//  SynonymsView.swift
//  LeitnerBox
//
//  Created by hamed on 8/19/22.
//

import SwiftUI

struct SynonymsView: View {

    @ObservedObject
    var viewModel: SynonymViewModel

    var body: some View {
        List(viewModel.allSynonymsInLeitner) { synonym in

            VStack(alignment: .leading) {
                let firstQuestion = synonym.allQuestions.first
                Text(firstQuestion?.question ?? "")
                    .font(.title3.bold())

                let allQuestions = synonym.allQuestions.filter({$0 != firstQuestion})
                ScrollView(.horizontal){
                    HStack(spacing:4){
                        ForEach(allQuestions) { question in
                            Text("\(String(question.question?.split(separator: "\n").first ?? ""))")
                                .foregroundColor(.accentColor)
                                .font(.footnote.weight(.semibold))
                                .padding([.top, .bottom], 4)
                                .padding([.trailing, .leading], 8)
                                .background(.blue.opacity(0.3))
                                .cornerRadius(6)
                                .transition(.asymmetric(insertion: .slide, removal: .scale))
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Synonyms")
        .listStyle(.plain)
    }
}

struct SynonymsView_Previews: PreviewProvider {
    static var previews: some View {
        SynonymsView(viewModel: .init(viewContext: PersistenceController.preview.container.viewContext, question: Question()))
    }
}
