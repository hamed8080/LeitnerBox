//
//  LeitnerRowView.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import SwiftUI

struct LeitnerRowView: View {
    
    @ObservedObject
    var leitner:Leitner
    
    @ObservedObject
    var vm:LeitnerViewModel
    
    var body: some View {
        NavigationLink {
            LevelsView(vm: LevelsViewModel(leitner: leitner), searchViewModel: SearchViewModel(leitner: leitner))
        } label: {
            HStack{
                Text(leitner.name ?? "")
                Spacer()
                Text(verbatim: "\(leitner.totalQuestionCount)")
                    .foregroundColor(.gray)
                    .font(.footnote.bold())
            }
            .contextMenu{
                Button {
                    vm.selectedLeitner = leitner
                    vm.leitnerTitle = vm.selectedLeitner?.name ?? ""
                    vm.backToTopLevel = leitner.backToTopLevel
                    vm.showEditOrAddLeitnerAlert.toggle()
                } label: {
                    Label("Rename and Edit", systemImage: "gear")
                }
                
                Button {
                    vm.selectedLeitner = leitner                    
                    vm.navigateToManageTags.toggle()
                } label: {
                    Label("Manage Tags", systemImage: "tag")
                }
            }
        }
    }
}

struct LeitnerRowView_Previews: PreviewProvider {
    static var previews: some View {
        LeitnerRowView(leitner: LeitnerView_Previews.leitner, vm: LeitnerViewModel(isPreview: true))
    }
}
