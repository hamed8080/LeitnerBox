//
//  DateEx.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import Foundation
extension Date{
    
    func differenceWith(from date:Date)->DateComponents{
        let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: self)
        return diffs
    }
}
