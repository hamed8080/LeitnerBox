//
//  StringEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/31/22.
//

import Foundation
extension String{
    
    var persianAlphabet:[Character]{
        let characters = Array("وپضصثقفغعهخحجچشسیبلاتنمظطزرذدپًٌٍَُِّْؤئيإأآةكٓژٰ‌‌ٔء،۱۲۳۴۵۶۷۸۹۰")
        return characters
    }
    
    var isContainPersianCharacter:Bool{
        if self.isEmpty { return false }
        var isContains = false
        persianAlphabet.forEach { character in
            if self.contains(character){
                isContains = true
            }
        }
        return isContains
    }
}
