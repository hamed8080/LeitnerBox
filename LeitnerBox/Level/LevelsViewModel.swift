//
//  LevelsViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

class LevelsViewModel:ObservableObject{
   
    @Published
    var viewContext:NSManagedObjectContext = PersistenceController.shared.container.viewContext
    
    @Published
    var leitner:Leitner
    
    @Published
    var searchWord:String = ""
    
    @Published
    var showSearchView:Bool = false
    
    @Published
    var showAddQuestionView = false
    
    @Published
    var levels: [Level] = []
    
    @Published
    var allQuestions:[Question] = []
    
    @Published
    var suggestions:[Question] = []
    
    init(leitner:Leitner, isPreview:Bool = false ){
        viewContext = isPreview ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
        self.leitner = leitner
        
        self.leitner = leitner
        let predicate = NSPredicate(format: "leitner.id == %d", self.leitner.id)
        let req = Level.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Level.level, ascending: true)]
        req.predicate = predicate
        do {
            self.levels = try viewContext.fetch(req)
        }catch{
            print("Fetch failed: Error \(error.localizedDescription)")
        }
        levels.forEach { level in
            (level.questions?.allObjects as? [Question])?.forEach({ question in
                allQuestions.append(question)
            })
        }
    }

}
