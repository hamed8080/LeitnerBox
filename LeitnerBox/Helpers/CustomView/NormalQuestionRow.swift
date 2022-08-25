//
//  NormalQuestionRow.swift
//  LeitnerBox
//
//  Created by hamed on 8/21/22.
//

import SwiftUI

struct NormalQuestionRow: View {

    @ObservedObject
    var question: Question

    @ObservedObject
    var tagsViewModel: TagViewModel

    @ObservedObject
    var searchViewModel: SearchViewModel
    
    var showControls = false

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.dynamicTypeSize)
    var typeSize

    var tagCompletion:(()->())? = nil

    public init (question: Question, tagsViewModel: TagViewModel, searchViewModel: SearchViewModel? = nil, showControls: Bool = false, tagCompletion:(()->())? = nil) {
        self.question = question
        self.tagsViewModel = tagsViewModel
        self.showControls = showControls
        self.searchViewModel = searchViewModel ?? SearchViewModel(viewContext: tagsViewModel.viewContext, leitner: tagsViewModel.leitner)
        self.showControls = showControls
        self.tagCompletion = tagCompletion
    }

    var body: some View {
        HStack{
            if sizeClass == .regular && typeSize == .large{
                ipadView
            }else{
                iphoneView
            }
        }
    }

    var ipadView:some View{
        VStack(alignment:.leading, spacing: 4){
            questionAndAnswer
                .padding(.top, 8)
                .padding([.leading,.trailing])
            HStack{
                levelAndAvailibility
                Spacer()
                completed
                controls
            }
            .padding([.leading, .trailing])

            QuestionTagsView(
                question: question,
                showAddButton: showControls,
                viewModel: tagsViewModel,
                addPadding: true
            ){
                tagCompletion?()
            }
        }
    }

    var iphoneView:some View{
        VStack{
            VStack(alignment:.leading, spacing: 4){
                questionAndAnswer
                levelAndAvailibility
                HStack{
                    completed
                    Spacer()
                    controls
                }
            }.padding()

            QuestionTagsView(
                question: question,
                showAddButton: showControls,
                viewModel: tagsViewModel,
                addPadding: true
            ){
                tagCompletion?()
            }
        }
    }

    var levelAndAvailibility:some View{
        HStack{
            Text(verbatim: "LEVEL: \(question.level?.level ?? 0)")
                .foregroundColor(.blue)
                .font(.footnote.bold())

            Text(question.remainDays)
                .foregroundColor(.gray)
                .font(.footnote.bold())
        }
    }

    @ViewBuilder
    var questionAndAnswer:some View{
        Text(question.question ?? "")
            .font(.title2.bold())
        if let answer = question.answer, !answer.isEmpty {
            Text(answer.uppercased())
                .foregroundColor(.gray)
                .font(.headline.bold())
        }

        if let detailDescription = question.detailDescription, !detailDescription.isEmpty{
            Text(detailDescription.uppercased())
                .foregroundColor(.gray)
                .font(.headline.bold())
        }
    }

    @ViewBuilder
    var completed:some View{
        if question.completed{
            Text("COMPLETED")
                .foregroundColor(.blue)
                .font(.footnote.bold())
        }
    }

    @ViewBuilder
    var controls:some View{
        if showControls {
            let padding:CGFloat = sizeClass == .compact ? 4 : 8
            HStack(spacing: padding){
                let controlSize:CGFloat = 24
                Button {
                    searchViewModel.pronounceOnce(question)
                } label: {
                    Image(systemName: "mic.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: controlSize, height: controlSize)
                        .padding(padding)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.borderless)

                Button {
                    withAnimation {
                        searchViewModel.toggleFavorite(question)
                    }
                } label: {

                    Image(systemName: question.favorite ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: controlSize, height: controlSize)
                        .padding(padding)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.borderless)

                Menu {
                    Button(role: .destructive) {
                        withAnimation {
                            searchViewModel.delete(question)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Divider()

                    Button {
                        searchViewModel.editQuestion = question
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        UIPasteboard.general.string = [question.question, question.answer, question.detailDescription]
                            .compactMap{$0?.trimmingCharacters(in: .whitespacesAndNewlines)}
                            .filter{ !$0.isEmpty }
                            .joined(separator: "\n")
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }

                    Button {
                        withAnimation {
                            searchViewModel.resetToFirstLevel(question)
                        }
                    } label: {
                        Label("Reset to first level", systemImage: "goforward")
                    }

                    Button {
                        withAnimation {
                            searchViewModel.complete(question)
                        }
                    } label: {
                        Label("Mark as completed", systemImage: "tray.full")
                    }

                    Divider()

                    Menu("Move"){
                        let vm = LeitnerViewModel(viewContext: PersistenceController.shared.container.viewContext)
                        ForEach(vm.leitners){ leitner in
                            Button {
                                withAnimation {
                                    self.searchViewModel.moveQuestionTo(question, leitner: leitner)
                                }
                            } label: {
                                Label( "\(leitner.name ?? "")", systemImage: "folder")
                            }
                        }
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: controlSize, height: controlSize)
                        .padding(padding)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct NormalQuestionRow_Previews: PreviewProvider {
    static var previews: some View {
        let leitner  = LeitnerView_Previews.leitner
        let question = leitner.levels.filter({$0.level == 1}).first?.allQuestions.first as? Question
        let tagVM = TagViewModel(viewContext: PersistenceController.previewVC, leitner: leitner)
        let searchVM = SearchViewModel(viewContext: PersistenceController.previewVC, leitner: leitner)
        NormalQuestionRow(question: question!, tagsViewModel: tagVM, searchViewModel: searchVM)
    }
}
