//
//  SynonymEX.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import Foundation
extension Synonym{

    var allQuestions:[Question]{
        return question?.allObjects as? [Question] ?? []
    }
}
