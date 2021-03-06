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
    
    func findQuestion(objectID:NSManagedObjectID?)->Question?{
        guard let objectID = objectID else { return nil }
        return  allQuestions.first(where: {$0.objectID == objectID})
    }
}
