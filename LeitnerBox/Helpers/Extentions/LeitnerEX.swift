//
//  LeitnerEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import Foundation
extension Leitner{
    
    var totalQuestionCount:Int{
        guard let levels = level?.allObjects as? [Level] else{ return 0 }
        return levels.map{$0.questions?.count ?? 0}.reduce(0,+)
    }
}
