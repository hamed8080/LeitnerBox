//
//  CheckBoxView.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import SwiftUI

struct CheckBoxView:View{
    
    @Binding
    var isActive:Bool
    
    let text:String
    
    var body: some View{
        Button {
            isActive.toggle()
        } label: {
            HStack{
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(text)
                Spacer()
            }
        }

    }
}
