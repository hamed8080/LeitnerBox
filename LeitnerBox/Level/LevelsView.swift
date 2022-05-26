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
    
    var body: some View {
        
        ZStack{
            List {
                HeaderView(levels: vm.levels)
                ForEach(vm.levels) { level in
                    LevelRow(vm: vm, reviewViewModel: ReviewViewModel(level: level))
                }
            }
            .listStyle(.plain)
            
            NavigationLink(isActive:$vm.showSearchView) {
                SearchView(vm: SearchViewModel(leitner: vm.leitner))
            } label: {
                EmptyView()
            }
            
            NavigationLink(isActive: $vm.showAddQuestionView) {
                if let levelFirst = vm.levels.first(where: {$0.level == 1}){
                    AddOrEditQuestionView(vm: .init(level: levelFirst))
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }
        .searchable(text: $vm.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
            if vm.suggestions.count > 0 || vm.searchWord.isEmpty{
                ForEach(vm.suggestions){ suggestion in
                    SearchRowView(question: suggestion, vm: SearchViewModel(leitner: vm.leitner))
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
        .onChange(of: vm.searchWord) { newValue in
            vm.suggestions = vm.allQuestions.filter({
                $0.question?.lowercased().contains( vm.searchWord.lowercased()) ?? false ||
                $0.answer?.lowercased().contains( vm.searchWord.lowercased()) ?? false ||
                $0.detailDescription?.lowercased().contains( vm.searchWord.lowercased()) ?? false
            })
        }
        .animation(.easeInOut, value: vm.suggestions)
        .navigationTitle(vm.levels.first?.leitner?.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
               
                Button {
                    vm.showAddQuestionView.toggle()
                } label: {
                    Label("Add Item", systemImage: "plus.square")
                }
                
                Button {
                    vm.showSearchView.toggle()
                } label: {
                    Label("Search View", systemImage: "list.bullet.rectangle.portrait")
                }
            }
        }
        .customDialog(isShowing: $vm.showDaysAfterDialog, content: {
            daysToRecommendDialogView
        })
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
        LevelsView(vm: LevelsViewModel(leitner: LeitnerView_Previews.leitner))
            .previewDevice("iPhone 13 Pro Max")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}


struct HeaderView: View {
    
    let levels:[Level]
    
    var body: some View {
        VStack(alignment:.leading, spacing: 4){
            let totalCount = levels.map{$0.questions?.count ?? 0}.reduce(0,+)
            
            let completedCount = levels.map{ level in
                let completedCount = (level.questions?.allObjects as? [Question] )?.filter({
                    return $0.completed == true
                })
                return completedCount?.count ?? 0
            }.reduce(0,+)
        
            let reviewableCount = levels.map{ level in
                level.reviewableCountInsideLevel
            }.reduce(0,+)
            
            let text = "\(totalCount) total, \(completedCount) completed, \(reviewableCount) reviewable".uppercased()
            
            Text(text)
                .font(.footnote.weight(.bold))
                .foregroundColor(.gray)
        }
        .listRowSeparator(.hidden)
    }
    
}
