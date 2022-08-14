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
        return passTime.advanced(by: Double(daysToRecommend * (24 * 3600))) <= Date() && completed == false
    }
    
    var remainDays:String{
        let daysToRecommend = level?.daysToRecommend ?? 0
        if let passTime, passTime.advanced(by: Double(daysToRecommend * (24 * 3600))) >= Date(){
            let components = passTime.advanced(by: Double(daysToRecommend * (24 * 3600))).differenceWith(from: Date())
            
            let days = (components.day ?? 0)
            let daysString = days > 0 ? "\(days) days " : ""
            let hours = components.hour ?? 0
            let hoursString = hours > 0 ? " \(hours) hours " : ""
            let minutes = components.minute ?? 0
            let minutesString = minutes > 0 ? " \(minutes) minutes " : ""
            return "\(daysString)\(hoursString)\(minutesString) left".uppercased()
        }else{
            return "Available".uppercased()
        }
    }
    
    var upperLevel:Level?{
        let levels = level?.leitner?.levels
        return levels?.filter({(level?.level ?? 0) + 1 == $0.level }).first
    }
    
    var firstLevel:Level?{
        let levels = level?.leitner?.levels
        return levels?.filter{ $0.level == 1 }.first
    }
    
    var tagsArray:[Tag]?{
        return tag?.allObjects as? [Tag]
    }
}
