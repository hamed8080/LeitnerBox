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
    
    var tagsArray:[Tag]{
        guard let tags =  tag?.allObjects as? [Tag] else{ return [] }
        return tags
    }
    
    var firstLevel:Level?{
        let levels = level?.allObjects as? [Level]
        return levels?.filter{ $0.level == 1 }.first
    }

    var totalReviewableCount:Int{
        let levels = level?.allObjects as? [Level]
        let levelCountsArray = levels?.map{
            level in level.questions?.filter{ ($0 as? Question)?.isReviewable ?? false }.count ?? 0
        }
        return levelCountsArray?.reduce(0, +) ?? 0
    }

    var succcessPercentage:Double{
        return (Double(totalReviewableCount) / Double(totalQuestionCount)) * 100
    }

}
