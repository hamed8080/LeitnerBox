//
// SearchRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct SearchRowView: View {
    @StateObject
    var question: Question

    @StateObject
    var leitner: Leitner

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.dynamicTypeSize)
    var typeSize

    var body: some View {
        NormalQuestionRow(question: question, tagsViewModel: .init(viewContext: context, leitner: leitner))
    }
}

struct SearchRowView_Previews: PreviewProvider {
    struct Preview: View {
        let leitner = LeitnerView_Previews.leitner
        let question = LeitnerView_Previews.leitner.levels.filter { $0.level == 1 }.first?.allQuestions.first as? Question

        var body: some View {
            SearchRowView(question: question ?? Question(context: PersistenceController.shared.viewContext), leitner: leitner)
                .environmentObject(SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice))
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        Preview()
    }
}
