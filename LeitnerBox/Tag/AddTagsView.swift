//
//  AddTagsView.swift
//  LeitnerBox
//
//  Created by hamed on 8/18/22.
//

import SwiftUI

struct AddTagsView: View{

    @ObservedObject
    var question: Question

    @StateObject
    var viewModel: TagViewModel

    @Environment(\.dismiss)
    var dismiss

    var body: some View{
        VStack(spacing: 0){

            TopSheetTextEditorView(searchText: $viewModel.searchText, placeholder: "Search for tags...")

            List{
                ForEach(viewModel.filtered) { tag in
                    Label(tag.name ?? "", systemImage: "tag")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.addToTag(tag, question)
                            dismiss()
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.filtered)
            .listStyle(.plain)
        }
    }
}

struct AddTagsView_Previews: PreviewProvider {
    static var previews: some View {
        let leitner = LeitnerView_Previews.leitner
        let viewContext = PersistenceController.preview.container.viewContext
        let question = leitner.allQuestions.first!
        AddTagsView(question: question, viewModel: .init(viewContext: viewContext, leitner: leitner))
            .preferredColorScheme(.dark)
    }
}
