//
//  AddSynonymsView.swift
//  LeitnerBox
//
//  Created by hamed on 8/18/22.
//

import SwiftUI

struct AddSynonymsView: View{

    @ObservedObject
    var viewModel: SynonymViewModel

    @Environment(\.dismiss)
    var dismiss

    var body: some View{
        VStack(spacing: 0){

            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for synonyms...")

            List{
                ForEach(viewModel.filtered) { question in
                    VStack(alignment: .leading, spacing: 4){
                        Text(question.question ?? "")
                            .font(.title2.bold())
                        if let answer = question.answer, !answer.isEmpty {
                            Text(answer.uppercased())
                                .foregroundColor(.gray)
                                .font(.headline.bold())
                                .padding()
                        }

                        if let detailDescription = question.detailDescription, !detailDescription.isEmpty{
                            Text(detailDescription.uppercased())
                                .foregroundColor(.gray)
                                .font(.headline.bold())
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.addAsSynonym(question)
                        dismiss()
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.filtered)
            .listStyle(.plain)
        }
    }
}

struct AddSynonymsView_Previews: PreviewProvider {
    static var previews: some View {
        let firstQuestion = LeitnerView_Previews.leitner.allQuestions.first!
        AddSynonymsView(viewModel: .init(viewContext: PersistenceController.preview.container.viewContext, question: firstQuestion))
            .preferredColorScheme(.dark)
    }
}
