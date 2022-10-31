//
// SearchRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI
import CoreData

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
        let tagsVM = TagViewModel(viewContext: context, leitner: leitner)
        NormalQuestionRow(question: question, tagsViewModel: tagsVM) {
            withAnimation {
                PersistenceController.saveDB(viewContext: context)
            }
        }
    }
}

struct SearchRowView_Previews: PreviewProvider {
    struct Preview: View {
        let leitner = LeitnerView_Previews.leitner
        let question = LeitnerView_Previews.leitner.levels.filter { $0.level == 1 }.first?.allQuestions.first as? Question

        var body: some View {
            SearchRowView(question: question ?? Question(context: PersistenceController.shared.viewContext), leitner: leitner)
                .environmentObject(SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice ))
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        Preview()
    }
}
