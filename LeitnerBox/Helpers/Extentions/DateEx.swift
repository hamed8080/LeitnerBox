//
//  DateEx.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import Foundation
extension Date{
    
    func differenceWith(date:Date)->DateComponents{
        let diffs = Calendar.current.dateComponents([.year, .month, .day], from: self, to: date)
        return diffs
    }
}
