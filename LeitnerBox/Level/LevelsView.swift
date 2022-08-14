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
                if vm.filtered.count >= 1 {
                    searchResult
                }else{
                    header
                    ForEach(vm.levels) { level in
                        LevelRow(vm: vm, reviewViewModel: ReviewViewModel(viewContext: PersistenceController.shared.container.viewContext, level: level))
                    }
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
                let completedCount = level.allQuestions.filter({
                    return $0.completed == true
                })
                return completedCount.count
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
                AddOrEditQuestionView(vm: .init(viewContext: PersistenceController.shared.container.viewContext, level: levelFirst))
            }
        } label: {
            Label("Add Item", systemImage: "plus.square")
        }
        
        NavigationLink {
            SearchView(vm: SearchViewModel(viewContext: PersistenceController.shared.container.viewContext, leitner: vm.leitner))
        } label: {
            Label("Search View", systemImage: "list.bullet.rectangle.portrait")
        }
        
        NavigationLink{
            TagView(vm: TagViewModel(viewContext: PersistenceController.shared.container.viewContext, leitner: vm.leitner))
        } label: {
            Label("Tags", systemImage: "tag")
        }
        
        NavigationLink{
            StatisticsView(vm: .init())
        } label: {
            Label("Statictics", systemImage: "chart.xyaxis.line")
        }
    }
    
    @ViewBuilder
    var searchResult:some View{
        if vm.filtered.count > 0 || vm.searchWord.isEmpty{
            ForEach(vm.filtered){ suggestion in
                SearchRowView(question: suggestion, vm: searchViewModel)
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
    
    struct Preview: View{
        
        @ObservedObject
        var vm = LevelsViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)
        
        @ObservedObject
        var searchViewModel = SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)
        
        var body: some View{
            LevelsView(vm: vm, searchViewModel: searchViewModel)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
    
    static var previews: some View {
        NavigationStack{
            Preview()
        }
    }
}
