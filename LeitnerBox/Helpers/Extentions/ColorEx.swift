//
//  ColorEx.swift
//  ChatApplication
//
//  Created by Hamed Hosseini on 11/30/21.
//

import Foundation
import SwiftUI

extension Color{
    
    init(named:String){
        self = Color(UIColor(named: named)!)
    }
    
    static var random:Color{
        return Color(uiColor: UIColor.random())
    }
}
