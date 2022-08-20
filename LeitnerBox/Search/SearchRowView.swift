//
//  SearchRowView.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import SwiftUI

struct SearchRowView: View {
    
    @ObservedObject
    var question:Question
    
    @ObservedObject
    var vm:SearchViewModel

    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @Environment(\.dynamicTypeSize)
    var typeSize
    
    var body: some View {
        let searchVM = SearchViewModel(viewContext: vm.viewContext, leitner: vm.leitner)
        let tagsVM = TagViewModel(viewContext: vm.viewContext, leitner: vm.leitner)
        NormalQuestionRow(question: question, tagsViewModel: tagsVM, searchViewModel: searchVM, showControls: true)
    }
}

struct SearchRowView_Previews: PreviewProvider {
    
    static var tag:Tag{
        let req = Tag.fetchRequest()
        req.fetchLimit = 1
        let tag = (try! PersistenceController.preview.container.viewContext.fetch(req)).first!
        return tag
    }
    
    static var previews: some View {
        let leitner  = LeitnerView_Previews.leitner
        let question = leitner.levels.filter({$0.level == 1}).first?.allQuestions.first as? Question
        SearchRowView(question: question ?? Question(context: PersistenceController.preview.container.viewContext), vm: SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: leitner))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
