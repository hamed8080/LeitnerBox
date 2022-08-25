//
//  SearchView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct SearchView: View {
    
    @ObservedObject
    var vm:SearchViewModel

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            List {
                ForEach(vm.filtered) { item in
                    SearchRowView(question: item, vm: vm)
                        .listRowInsets(EdgeInsets())
                }
                .onDelete(perform: vm.deleteItems)
            }
            .if(.iOS){ view in
                view.refreshable {
                    vm.viewContext.rollback()
                    vm.reload()
                }
            }
            .navigationDestination(isPresented: Binding(get: {return vm.editQuestion != nil}, set: {_ in})) {
                if let editQuestion = vm.editQuestion {
                    let level = editQuestion.level ?? vm.leitner.firstLevel
                    AddOrEditQuestionView(vm: .init(viewContext: vm.viewContext, level: level!, question: editQuestion, isInEditMode: true))
                        .onDisappear {
                            vm.editQuestion = nil
                        }
                }
            }
            .animation(.easeInOut, value: vm.filtered)
            .listStyle(.plain)
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
                if vm.searchText.isEmpty == false && vm.filtered.count < 1{
                    HStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.gray.opacity(0.8))
                        Text("Nothind has found.")
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            pronunceWordsView
        }
        .animation(.easeInOut, value: vm.filtered)
        .animation(.easeInOut, value: vm.isSpeaking)
        .navigationTitle(Text("Advance Search in \(vm.leitner.name ?? "")"))
        .onAppear(perform: {
            vm.viewDidAppear()
        })
        .toolbar {
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack{
                    NavigationLink(destination: LazyView(AddOrEditQuestionView(vm:
                            .init(
                                viewContext: vm.viewContext,
                                level: insertQuestion.level!,
                                question: insertQuestion,
                                isInEditMode: false
                            )
                    ))) {
                        Label("Add", systemImage: "plus.square")
                    }

                    Button {
                        vm.stopReview()
                    } label: {
                        Label("Stop", systemImage: "stop.circle")
                    }
                    .disabled(!vm.isSpeaking)


                    Button {
                        vm.pauseReview()
                    } label: {
                        Label("Pause", systemImage: "pause.circle")
                    }
                    .disabled(!vm.isSpeaking)


                    Button {
                        vm.playReview()
                    } label: {
                        Label("Play", systemImage: "play.square")
                    }.disabled(vm.isSpeaking)

                    Button {
                        vm.playNextImmediately()
                    } label: {
                        Label("Next", systemImage: "forward.end")
                            .foregroundStyle(Color.accentColor)
                    }.disabled(!vm.isSpeaking)

                    Menu {
                        Text("Sort By")

                        ForEach(searchSorts, id:\.self){ sortItem in
                            Button {
                                withAnimation {
                                    vm.sort(sortItem.sortType)
                                }
                            } label: {
                                let favoriteCount = vm.leitner.allQuestions.filter{$0.favorite == true}.count
                                let countText = sortItem.sortType == .FAVORITE ? " (\(favoriteCount))" : ""
                                Label( "\(vm.selectedSort == sortItem.sortType ? "✔︎ " : "")" + sortItem.title + countText, systemImage: sortItem.iconName)
                            }
                        }

                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
                .font(.title3)
                .symbolRenderingMode(.palette)
                .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
            }

        }
    }

    var insertQuestion: Question{
        let firstLevel = vm.leitner.firstLevel
        let question = Question(context: vm.viewContext)
        question.level = firstLevel
        return question
    }

    @ViewBuilder
    var pronunceWordsView:some View{
        if vm.isSpeaking{
            VStack(alignment:.leading){
                Spacer()
                HStack{
                    HStack{
                        
                        if vm.lastPlayedQuestion?.favorite == true{
                            Image(systemName:"star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .foregroundColor(.accentColor)
                        }
                        
                        VStack(alignment:.leading, spacing: 8){
                            Text(verbatim: vm.lastPlayedQuestion?.question ?? "")
                                .foregroundColor(.primary)
                                .font(.title.weight(.bold))
                            Text(verbatim: vm.lastPlayedQuestion?.answer ?? "")
                                .foregroundColor(.primary)
                                .font(.body.weight(.medium))
                            Text(verbatim: vm.lastPlayedQuestion?.detailDescription ?? "")
                                .foregroundColor(.primary)
                                .font(.body.weight(.medium))
                            Text(verbatim: "\(vm.reviewdCount) / \(vm.leitner.allQuestions.count)")
                                .font(.footnote.bold())
                            if let question = vm.lastPlayedQuestion {
                                QuestionTagsView(
                                    question: question,
                                    showAddButton: false,
                                    viewModel: .init(viewContext: vm.viewContext, leitner: vm.leitner)
                                )
                                .frame(maxHeight:64)
                            }
                        }
                        
                    }
                    Spacer()
                }
                .padding()
                .padding(.bottom, 24)
                .background(
                    Color(named: "reviewBackground")
                        .cornerRadius(24, corners: [.topLeft,.topRight])
                        .shadow(radius: 5)
                )
            }
            .animation(.easeInOut, value: vm.lastPlayedQuestion)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    
    struct Preview: View{
        
        @ObservedObject
        var vm = SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)
        var body: some View{
            SearchView(vm: vm)
                .onAppear{
                    vm.isSpeaking = false
                }
        }
    }
    
    static var previews: some View {
        NavigationStack{
            Preview()
        }
    }
}
