//
//  LeitnerBox.swift
//  ChatApplication
//
//  Created by hamed on 5/19/22.
//

import SwiftUI

extension View {
    
    var isIpad:Bool{
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
