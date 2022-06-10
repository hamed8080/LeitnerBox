//
//  LevelRow.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import SwiftUI

struct LevelRow:View{
    
    @ObservedObject
    var vm:LevelsViewModel
    
    /// Do not move this to view it cause view reload in review
    @ObservedObject
    var reviewViewModel:ReviewViewModel
    
    var body: some View{
        NavigationLink {
            ReviewView(vm: reviewViewModel)
        } label: {
            HStack{
                HStack{
                    Text(verbatim: "\(reviewViewModel.level.level)")
                        .foregroundColor(.white)
                        .font(.title.weight(.bold))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                    let favCount = (reviewViewModel.level.questions?.allObjects as? [Question] )?.filter({ $0.favorite == true }).count
  
                    HStack(alignment:.firstTextBaseline, spacing: 4){
                        Image(systemName: "star.fill")
                            .foregroundColor(.accentColor)
                        Text(verbatim: "\(favCount ?? 0)")
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
       
                HStack(spacing:0){
                    Text(verbatim: " \(reviewViewModel.level.reviewableCountInsideLevel)")
                        .foregroundColor(.green.opacity(1))
                    Text(verbatim: " / \(reviewViewModel.level.notCompletdCount)")
                        .foregroundColor(.primary.opacity(1))
                }
                
            }
            .contextMenu{
                Button {
                    vm.selectedLevel = reviewViewModel.level
                    vm.daysToRecommend = Int(reviewViewModel.level.daysToRecommend)
                    vm.showDaysAfterDialog.toggle()
                } label: {
                    Label("Days to recommend", systemImage: "calendar")
                }
            }
            .padding([.leading, .top, .bottom] , 8)
        }
    }
}


struct LevelRow_Previews: PreviewProvider {
    static var previews: some View {
        LevelRow(vm: LevelsViewModel(leitner: LeitnerView_Previews.leitner), reviewViewModel: ReviewViewModel(level: LeitnerView_Previews.leitner.level?.allObjects.first as! Level))
    }
}
