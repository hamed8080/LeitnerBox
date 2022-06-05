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
    
    var body: some View {
        ZStack{
            
            List {
                ForEach(vm.questions) { item in
                    SearchRowView(question: item, vm: vm)
                }
                .onDelete(perform: vm.deleteItems)
            }
            .animation(.easeInOut, value: vm.filtered)
            .listStyle(.plain)
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
                if vm.filtered.count > 0 || vm.searchText.isEmpty{
                    ForEach(vm.filtered){ question in
                        SearchRowView(question: question, vm: vm)
                    }
                }else{
                    HStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.gray.opacity(0.8))
                        Text("Nothind has found.")
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            .if(.iOS){ view in
                view.refreshable {
                    vm.load()
                }
            }
            
            pronunceWordsView
        
            NavigationLink(isActive:$vm.showAddQuestionView) {
                let levels = vm.leitner.level?.allObjects as? [Level]
                let firstLevel = levels?.first(where: {$0.level == 1})
                AddOrEditQuestionView(vm: .init(level:  firstLevel!, editQuestion: vm.selectedQuestion)){ questionState in
                    vm.qustionStateChanged(questionState)
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }
        .animation(.easeInOut, value: vm.questions)
        .animation(.easeInOut, value: vm.filtered)
        .animation(.easeInOut, value: vm.isSpeaking)
        .navigationTitle("Advance Search in \(vm.leitner.name ?? "")")
        .onAppear(perform: {
            vm.viewDidAppear()
        })
        .toolbar {
            ToolbarItem {
                Button {
                    vm.selectedQuestion = nil
                    vm.showAddQuestionView.toggle()
                } label: {
                    Label("Add", systemImage: "plus.square")
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
               
                Button {
                    vm.stopReview()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .disabled(!vm.isSpeaking)
                
                
                Button {
                    vm.pauseReview()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                }
                .disabled(!vm.isSpeaking)
                
                
                Button {
                    vm.playReview()
                } label: {
                    Label("Play", systemImage: "play.fill")
                }.disabled(vm.isSpeaking)
                
                Button {
                    vm.playNextImmediately()
                } label: {
                    Label("Next", systemImage: "forward.end.fill")
                }.disabled(!vm.isSpeaking)
                
                Menu {
                    Text("Sort By")
                    
                    ForEach(searchSorts, id:\.self){ sortItem in
                        Button {
                            withAnimation {
                                vm.sort(sortItem.sortType)
                            }
                        } label: {
                            let favoriteCount = vm.questions.filter{$0.favorite == true}.count
                            let countText = sortItem.sortType == .FAVORITE ? " (\(favoriteCount))" : ""
                            Label( "\(vm.selectedSort == sortItem.sortType ? "✔︎ " : "")" + sortItem.title + countText, systemImage: sortItem.iconName)
                        }
                    }
                    
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
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
                            Text(verbatim: "\(vm.reviewdCount) / \(vm.questions.count)")
                                .font(.footnote.bold())
                            let tags = vm.lastPlayedQuestion?.tagsArray ?? []
                            QuestionTagsView(tags: tags)
                                .frame(maxHeight:64)
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
    
    static var vm:SearchViewModel{
        let vm = SearchViewModel(leitner: LeitnerView_Previews.leitner, isPreview: true)
        vm.isSpeaking = false
        return vm
    }
    
    static var previews: some View {
        SearchView(vm: vm)
            .preferredColorScheme(.light)
    }
}
