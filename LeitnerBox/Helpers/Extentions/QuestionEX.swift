//
//  QuestionEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/22/22.
//

import Foundation
extension Question{
    
    var isReviewable:Bool{
        guard let passTime = passTime else {return true}
        let daysToRecommend = level?.daysToRecommend ?? 0
        return passTime.advanced(by: Double(daysToRecommend * (24 * 3600))) <= Date()
    }
    
    var remainDays:String{
        let daysToRecommend = level?.daysToRecommend ?? 0
        if let passTime = passTime, passTime.advanced(by: Double(daysToRecommend * (24 * 3600))) >= Date(){
            let days = passTime.advanced(by: Double(daysToRecommend * (24 * 3600))).differenceWith(date: Date()).day
            return "\( abs(days ?? 0)) day left".uppercased()
        }else{
            return "Available".uppercased()
        }
    }
}
