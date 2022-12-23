//
// SearchRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct SearchRowView: View {
    @StateObject var question: Question
    @StateObject var leitner: Leitner
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        NormalQuestionRow(question: question, tagsViewModel: .init(viewContext: context, leitner: leitner))
    }
}

struct SearchRowView_Previews: PreviewProvider {
    struct Preview: View {
        static let context = PersistenceController.shared.viewContext
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        let question = Preview.leitner.levels.filter { $0.level == 1 }.first?.allQuestions.first as? Question

        var body: some View {
            SearchRowView(question: question ?? Question(context: Preview.context), leitner: Preview.leitner)
                .environmentObject(SearchViewModel(viewContext: Preview.context, leitner: Preview.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice))
                .environmentObject(LeitnerViewModel(viewContext: Preview.context))
                .environment(\.managedObjectContext, Preview.context)
        }
    }

    static var previews: some View {
        Preview()
    }
}
