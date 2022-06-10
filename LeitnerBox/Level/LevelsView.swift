//
//  LevelsView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct LevelsView: View {
    
    @ObservedObject
    var vm:LevelsViewModel
    
    @ObservedObject
    var searchViewModel:SearchViewModel
    
    var body: some View {
        
        ZStack{
            List {
                header
                ForEach(vm.levels) { level in
                    LevelRow(vm: vm, reviewViewModel: ReviewViewModel(level: level))
                }
            }
            .listStyle(.plain)
            .if(.iOS){ view in
                view.refreshable {
                    vm.load()
                }
            }
            .searchable(text: $vm.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
                searchResult
            }
            
            if searchViewModel.selectedQuestion != nil{
                NavigationLink{
                    let levels = searchViewModel.leitner.level?.allObjects as? [Level]
                    let firstLevel = levels?.first(where: {$0.level == 1})
                    AddOrEditQuestionView(vm: .init(level:  firstLevel!, editQuestion: searchViewModel.selectedQuestion)){ questionState in
                        searchViewModel.qustionStateChanged(questionState)
                        searchViewModel.selectedQuestion = nil
                    }
                } label: {
                    EmptyView()
                        .frame(width: 0, height: 0)
                }
                .hidden()
            }
        }
        .animation(.easeInOut, value: vm.searchWord)
        .navigationTitle(vm.levels.first?.leitner?.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbars
            }
        }
        .customDialog(isShowing: $vm.showDaysAfterDialog) {
            daysToRecommendDialogView
        }
    }
    
    @ViewBuilder
    var header:some View{
        VStack(alignment:.leading, spacing: 4){
            let totalCount = vm.levels.map{$0.questions?.count ?? 0}.reduce(0,+)
            
            let completedCount = vm.levels.map{ level in
                let completedCount = (level.questions?.allObjects as? [Question] )?.filter({
                    return $0.completed == true
                })
                return completedCount?.count ?? 0
            }.reduce(0,+)
            
            let reviewableCount = vm.levels.map{ level in
                level.reviewableCountInsideLevel
            }.reduce(0,+)
            
            let text = "\(totalCount) total, \(completedCount) completed, \(reviewableCount) reviewable".uppercased()
            
            Text(text)
                .font(.footnote.weight(.bold))
                .foregroundColor(.gray)
        }
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    var toolbars:some View{
        
        NavigationLink {
            if let levelFirst = vm.levels.first(where: {$0.level == 1}){
                AddOrEditQuestionView(vm: .init(level: levelFirst)){ questionState in
                    vm.questionStateChanged(state: questionState)
                }
            }
        } label: {
            Label("Add Item", systemImage: "plus.square")
        }
        
        NavigationLink {
            SearchView(vm: SearchViewModel(leitner: vm.leitner))
        } label: {
            Label("Search View", systemImage: "list.bullet.rectangle.portrait")
        }
        
        NavigationLink{
            TagView(vm: TagViewModel(leitner: vm.leitner))
        } label: {
            Label("Tags", systemImage: "tag")
        }
    }
    
    @ViewBuilder
    var searchResult:some View{
        if vm.filtered.count > 0 || vm.searchWord.isEmpty{
            ForEach(vm.filtered){ suggestion in
                SearchRowView(question: suggestion, vm: searchViewModel){ questionState in
                    vm.questionStateChanged(state: questionState)
                }
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
    
    var daysToRecommendDialogView:some View{
        VStack(spacing:24){
            Text(verbatim: "Level \(vm.selectedLevel?.level ?? 0)")
                .foregroundColor(.accentColor)
                .font(.title2.bold())
            
            Stepper(value: $vm.daysToRecommend, in: 1...365,step: 1) {
                Text(verbatim: "Days to recommend: \(vm.daysToRecommend)")
            }.onChange(of: vm.daysToRecommend) { newValue in
                vm.saveDaysToRecommned()
            }
            
            Button {
                vm.showDaysAfterDialog.toggle()
            } label: {
                HStack{
                    Spacer()
                    Text("Close")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }
}

struct LevelsView_Previews: PreviewProvider {
    static var previews: some View {
        LevelsView(vm: LevelsViewModel(leitner: LeitnerView_Previews.leitner),searchViewModel: SearchViewModel(leitner: LeitnerView_Previews.leitner))
            .previewDevice("iPhone 13 Pro Max")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}
