//
// LevelsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct LevelsView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @State var showDaysAfterDialog: Bool = false
    @Environment(\.isSearching) var isSearching

    var body: some View {
        List {
            if objVM.levelsVM.searchedQuestions.count >= 1 {
                searchResult
            } else {
                header
                ForEach(objVM.levelsVM.levels) { levelRowData in
                    LevelRow(levelRowData: levelRowData)
                }
            }
        }
        .listStyle(.plain)
        .if(.iOS) { view in
            view.refreshable {
                objVM.levelsVM.load()
            }
        }
        .onChange(of: isSearching) { newValue in
            objVM.levelsVM.isSearching = newValue
        }
        .searchable(text: $objVM.levelsVM.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...")
        .animation(.easeInOut, value: objVM.levelsVM.searchWord)
        .navigationTitle(objVM.leitner.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbars
            }
        }
    }

    @ViewBuilder var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            let text = "\(objVM.levelsVM.totalCount) total, \(objVM.levelsVM.completedCount) completed, \(objVM.levelsVM.reviewableCount) reviewable".uppercased()
            Text(text)
                .font(.footnote.weight(.bold))
                .foregroundColor(.gray)
        }
        .listRowSeparator(.hidden)
    }

    @ViewBuilder var searchResult: some View {
        if objVM.levelsVM.searchedQuestions.count > 0 || objVM.levelsVM.searchWord.isEmpty {
            ForEach(objVM.levelsVM.searchedQuestions) { question in
                NormalQuestionRow(question: question)
            }
        } else {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.gray.opacity(0.8))
                Text("Nothind has found.")
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
    }

    @ViewBuilder var toolbars: some View {
        ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
            AddOrEditQuestionView()
                .environmentObject(objVM)
        }
        .keyboardShortcut("a", modifiers: [.command, .option])

        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
            SearchView()
                .environmentObject(objVM)
        }
        .keyboardShortcut("f", modifiers: [.command, .option])

        ToolbarNavigation(title: "Tags", systemImageName: "tag.square") {
            TagView()
                .environmentObject(objVM)
        }
        .keyboardShortcut("t", modifiers: [.command, .option])

        ToolbarNavigation(title: "Statictics", systemImageName: "chart.xyaxis.line") {
            StatisticsView()
        }

        ToolbarNavigation(title: "Synonyms", systemImageName: "arrow.left.and.right.square") {
            SynonymsView()
                .environmentObject(objVM)
        }
        .keyboardShortcut("s", modifiers: [.command, .option])
    }
}

struct LevelsView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!

        @StateObject var viewModel = LevelsViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)

        @StateObject var searchViewModel = SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)

        var body: some View {
            LevelsView()
                .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(viewModel)
                .environmentObject(searchViewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
