//
// LevelsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct LevelsView: View {
    let container: ObjectsContainer
    @EnvironmentObject var viewModel: LevelsViewModel
    @Environment(\.isSearching) var isSearching

    var body: some View {
        List {
            header
            ForEach(viewModel.levels) { levelRowData in
                LevelRow(levelRowData: levelRowData, container: container)
            }
        }
        .listStyle(.plain)
        .overlay {
            LevelsSearchItemsOverlay(viewModel: viewModel, container: container)
        }
        .if(.iOS) { view in
            view.refreshable {
                viewModel.load()
            }
        }
        .onChange(of: isSearching) { newValue in
            viewModel.isSearching = newValue
        }
        .searchable(text: $viewModel.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...")
        .animation(.easeInOut, value: viewModel.searchWord)
        .navigationTitle(viewModel.leitner.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                LevelsToolbarView()
                    .environmentObject(container)
            }
        }
    }

    @ViewBuilder var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            let text = "\(viewModel.totalCount) total, \(viewModel.completedCount) completed, \(viewModel.reviewableCount) reviewable".uppercased()
            Text(text)
                .font(.footnote.weight(.bold))
                .foregroundColor(.gray)
        }
        .listRowSeparator(.hidden)
    }
}

struct LevelsToolbarView: View {
    @EnvironmentObject var container: ObjectsContainer

    var body: some View {
        ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
            AddOrEditQuestionView()
                .environmentObject(container)
        }
        .keyboardShortcut("a", modifiers: [.command, .option])

        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
            SearchView(container: container)
                .environmentObject(container.searchVM)
        }
        .keyboardShortcut("f", modifiers: [.command, .option])

        ToolbarNavigation(title: "Tags", systemImageName: "tag.square") {
            TagView()
                .environmentObject(container)
        }
        .keyboardShortcut("t", modifiers: [.command, .option])

        ToolbarNavigation(title: "Statictics", systemImageName: "chart.xyaxis.line") {
            StatisticsView()
        }

        ToolbarNavigation(title: "Synonyms", systemImageName: "arrow.left.and.right.square") {
            SynonymsView()
                .environmentObject(container)
        }
        .keyboardShortcut("s", modifiers: [.command, .option])
    }
}

struct LevelsView_Previews: PreviewProvider {
    struct Preview: View {
        static let context = PersistenceController.shared.viewContext
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        var leitnerViewModel: LeitnerViewModel {
            _ = PersistenceController.shared.generateAndFillLeitner()
            return LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)
        }
        @StateObject var viewModel = LevelsViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)
        @StateObject var searchViewModel = SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)

        var body: some View {
            LevelsView(container: ObjectsContainer(context: Preview.context, leitner: Preview.leitner, leitnerVM: leitnerViewModel))
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
