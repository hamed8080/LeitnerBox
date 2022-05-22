//
//  UIColor.swift
//  ChatApplication
//
//  Created by hamed on 4/12/22.
//

import Foundation
import UIKit

extension UIColor{
    
    static func random() -> UIColor {
        return UIColor(
            red   : .random(in : 0...1),
            green : .random(in : 0...1),
            blue  : .random(in : 0...1),
            alpha : 1.0
        )
    }
}

