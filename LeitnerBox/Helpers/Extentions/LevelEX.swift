//
//  LevelEXEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import Foundation
extension Level{
    
    var reviewableCountInsideLevel:Int{
        let questions = questions?.allObjects as? [Question]
        let reviewableCount = questions?.filter({ $0.isReviewable}).count
        return reviewableCount ?? 0
    }
    
    var hasAnyReviewable:Bool{
        let questions = questions?.allObjects as? [Question]
        let reviewableCount = questions?.filter({ $0.isReviewable}).count ?? 0
        return reviewableCount > 0
    }
}
