//
//  LeitnerEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import Foundation
import CoreData
extension Leitner{
    
    var totalQuestionCount:Int{
        guard let levels = level?.allObjects as? [Level] else{ return 0 }
        return levels.map{$0.questions?.count ?? 0}.reduce(0,+)
    }
    
    var tagsArray:[Tag]{
        guard let tags =  tag?.allObjects as? [Tag] else{ return [] }
        return tags
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

    var levels:[Level]{
        return level?.allObjects as? [Level] ?? []
    }
    
    var allQuestions:[Question]{
        let allQuestionInEachLevels = levels.map{$0.allQuestions}
        var arr: [Question] = []
        allQuestionInEachLevels.forEach { questionsInLevel in
            arr.append(contentsOf: questionsInLevel)
        }
        return arr
    }

    var firstLevel: Level?{
        levels.first(where: { $0.level == 1 })
    }
    
    func findQuestion(objectID:NSManagedObjectID?)->Question?{
        guard let objectID = objectID else { return nil }
        return  allQuestions.first(where: {$0.objectID == objectID})
    }
}
