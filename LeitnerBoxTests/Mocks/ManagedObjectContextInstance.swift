//
//  ManagedObjectContextInstance.swift
//  LeitnerBoxTests
//
//  Created by hamed on 3/3/23.
//

import Foundation
@testable import LeitnerBox

class ManagedObjectContextInstance {
    static let instance = ManagedObjectContextInstance()
    var leitners: [Leitner] = []
    private init(){
        leitners = PersistenceController.shared.generateAndFillLeitner()
    }

    func reset() {
        leitners = PersistenceController.shared.generateAndFillLeitner()
    }
}
