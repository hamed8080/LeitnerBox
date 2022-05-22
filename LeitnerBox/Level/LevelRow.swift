//
//  LevelRow.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import SwiftUI

struct LevelRow:View{
    
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
                    Text(verbatim: " / \(level.questions?.count ?? 0)")
                        .foregroundColor(.primary.opacity(1))
                }
                
            }
            .padding([.leading, .top, .bottom] , 8)
        }
    }
}


struct LevelRow_Previews: PreviewProvider {
    static var previews: some View {
        LevelRow(level: Level())
    }
}
