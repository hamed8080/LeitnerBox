//
//  TagEX.swift
//  LeitnerBox
//
//  Created by hamed on 6/3/22.
//

import Foundation
import SwiftUI
extension Tag{
    
    var tagSwiftUIColor:Color?{
        guard let uicColor = color as? UIColor else{return nil}
        return Color(uiColor: uicColor)
    }
   
    var questions:[Question]{
        return question?.allObjects as? [Question] ?? []
    }
}
