//
//  SynonymViewModel.swift
//  LeitnerBox
//
//  Created by hamed on 8/18/22.
//

import Foundation
import CoreData
import SwiftUI

class SynonymViewModel: ObservableObject{

    @Published
    var leitner: Leitner

    @Published
    var baseQuestion: Question

    @Published
    var viewContext:NSManagedObjectContext

    @Published
    var searchText:String = ""

    init(viewContext: NSManagedObjectContext, question: Question){
        self.viewContext = viewContext
        self.baseQuestion = question
        self.leitner = question.level!.leitner!
    }

    var filtered:[Question]{
        return leitner.allQuestions.filter({
            $0.question?.lowercased().contains( searchText.lowercased()) ?? false ||
            $0.detailDescription?.lowercased().contains( searchText.lowercased()) ?? false ||
            $0.answer?.lowercased().contains( searchText.lowercased()) ?? false ||
            $0.detailDescription?.lowercased().contains( searchText.lowercased()) ?? false
        })
    }

    func addAsSynonym(_ quesiton: Question){
        withAnimation {
            let synonym = baseQuestion.synonymsArray?.first ?? quesiton.synonymsArray?.first ?? Synonym(context: viewContext)
            synonym.addToQuestion(quesiton)
            synonym.addToQuestion(baseQuestion)
            objectWillChange.send()
        }
    }

    func deleteFromSynonym(_ question: Question){

        withAnimation{
            question.synonymsArray?.forEach{ synonym in
                synonym.removeFromQuestion(question)
            }
            objectWillChange.send()
        }
    }

    var allSynonymsInLeitner: [Synonym]{
        let req = Synonym.fetchRequest()
        return (try? viewContext.fetch(req)) ?? []
    }
}
