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
    
    @ObservedObject
    var level:Level
    
    var body: some View{
        NavigationLink {
            ReviewView(vm: ReviewViewModel(level: level))
        } label: {
            HStack{
                HStack{
                    Text(verbatim: "\(level.level)")
                        .foregroundColor(.white)
                        .font(.title.weight(.bold))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                    let favCount = (level.questions?.allObjects as? [Question] )?.filter({ $0.favorite == true }).count
  
                    Label {
                        Text(verbatim: "\(favCount ?? 0)")
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                }
                
                Spacer()
       
                
                
                HStack(spacing:0){
                    Text(verbatim: " \(level.reviewableCountInsideLevel)")
                        .foregroundColor(.green.opacity(1))
                    Text(verbatim: " / \(level.notCompletdCount)")
                        .foregroundColor(.primary.opacity(1))
                }
                
            }
            .contextMenu{
                Button {
                    vm.selectedLevel = level
                    vm.daysToRecommend = Int(level.daysToRecommend)
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
        LevelRow(vm: LevelsViewModel(leitner: LeitnerView_Previews.leitner), level: Level())
    }
}
