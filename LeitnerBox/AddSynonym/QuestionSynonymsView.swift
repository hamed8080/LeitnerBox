//
//  QuestionSynonymsView.swift
//  LeitnerBox
//
//  Created by hamed on 8/19/22.
//

import SwiftUI

struct QuestionSynonymsView: View {

    @ObservedObject
    var viewModel: SynonymViewModel
    
    @State
    var showAddSynonyms = false

    @State
    private var selectedQuestion:Question? = nil

    var body: some View{
        NavigationStack{
            VStack(alignment: .leading) {
                Button {
                    showAddSynonyms.toggle()
                } label: {
                    Label("Synonyms", systemImage: "plus.circle")
                }

                let synonym = viewModel.baseQuestion.synonymsArray ?? []
                let allSynonymsQuestions = (synonym.first?.allQuestions ?? []).filter({$0.objectID != viewModel.baseQuestion.objectID})
                ScrollView(.horizontal){
                    HStack(spacing:4){
                        ForEach(allSynonymsQuestions) { question in
                            Text("\(String(question.question?.split(separator: "\n").first ?? ""))")
                                .foregroundColor(.accentColor)
                                .font(.footnote.weight(.semibold))
                                .padding([.top, .bottom], 4)
                                .padding([.trailing, .leading], 8)
                                .background(.blue.opacity(0.3))
                                .cornerRadius(6)
                                .transition(.asymmetric(insertion: .slide, removal: .scale))
                                .onTapGesture {
                                    selectedQuestion = question
                                } //do not remove this line, it'll stop scrolling
                                .onLongPressGesture {
                                    viewModel.deleteFromSynonym(question)
                                }
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                        }
                    }
                    .padding([.bottom])
                }
                Spacer()
            }
        }
        .navigationDestination(isPresented: Binding(get: {return selectedQuestion != nil}, set: {vlaue in})){
            let level = selectedQuestion?.level ?? viewModel.leitner.firstLevel
            if let selectedQuestion {
                AddOrEditQuestionView(vm: .init(viewContext: viewModel.viewContext, level: level!, question: selectedQuestion, isInEditMode: true))
            }
        }
        .sheet(isPresented: $showAddSynonyms, onDismiss: nil, content: {
            AddSynonymsView(viewModel: viewModel)
        })
    }
}

