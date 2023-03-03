//
//  MigrationPolicyV1_V2.swift
//  LeitnerBox
//
//  Created by hamed on 3/2/23.
//

import CoreData

@objc(MigrationPolicyV1_V2)
class MigrationPolicyV1_V2: NSEntityMigrationPolicy {
    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        let context = manager.sourceContext
        let req = Question.fetchRequest()
        if let questions: [NSManagedObject] = try? context.fetch(req) {
            let duplicates = Dictionary(grouping: questions, by: { $0.value(forKey: "question") as? String }).filter { $1.count > 1 }
            for duplicate in duplicates {
                let firstQuestion = duplicate.value.first
                duplicate.value.forEach { question in
                    if question != firstQuestion {
                        context.delete(question)
                    }
                }
            }
        }
    }
}
