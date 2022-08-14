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
        let reviewableCount = questions?.filter({ $0.isReviewable && $0.completed == false}).count
        return reviewableCount ?? 0
    }
    
    var hasAnyReviewable:Bool{
        let questions = questions?.allObjects as? [Question]
        let reviewableCount = questions?.filter({ $0.isReviewable && $0.completed == false }).count ?? 0
        return reviewableCount > 0
    }
    
    var notCompletdCount:Int{
        let questions = questions?.allObjects as? [Question]
        return questions?.filter({$0.completed == false}).count ?? 0
    }
    
    var allQuestions:[Question]{
        return questions?.allObjects as? [Question] ?? []
    }
}
