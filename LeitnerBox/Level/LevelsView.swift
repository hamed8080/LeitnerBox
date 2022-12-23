//
// LevelsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct LevelsView: View {
    @EnvironmentObject var viewModel: LevelsViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @Environment(\.avSpeechSynthesisVoice) var voiceSpeech: AVSpeechSynthesisVoice
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
        ZStack {
            List {
                if viewModel.filtered.count >= 1 {
                    searchResult
                } else {
                    header
                    ForEach(viewModel.levels) { level in
                        LevelRow(level: level)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $viewModel.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...")
            .if(.iOS) { view in
                view.refreshable {
                    context.rollback()
                    viewModel.load()
                }
            }
            .navigationDestination(isPresented: Binding(get: { searchViewModel.editQuestion != nil }, set: { _ in })) {
                if let editQuestion = searchViewModel.editQuestion {
                    AddOrEditQuestionView(viewModel: .init(viewContext: context, leitner: searchViewModel.leitner, question: editQuestion))
                        .onDisappear {
                            searchViewModel.editQuestion = nil
                        }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.searchWord)
        .navigationTitle(viewModel.levels.first?.leitner?.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbars
            }
        }
    }

    @ViewBuilder var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            let totalCount = viewModel.levels.map { $0.questions?.count ?? 0 }.reduce(0, +)

            let completedCount = viewModel.levels.map { level in
                let completedCount = level.allQuestions.filter {
                    $0.completed == true
                }
                return completedCount.count
            }.reduce(0, +)

            let reviewableCount = viewModel.levels.map { level in
                level.reviewableCountInsideLevel
            }.reduce(0, +)

            let text = "\(totalCount) total, \(completedCount) completed, \(reviewableCount) reviewable".uppercased()

            Text(text)
                .font(.footnote.weight(.bold))
                .foregroundColor(.gray)
        }
        .listRowSeparator(.hidden)
    }

    @ViewBuilder var toolbars: some View {
        ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
            LazyView(
                AddOrEditQuestionView(viewModel: .init(viewContext: context, leitner: viewModel.leitner))
            )
        }
        .keyboardShortcut("a", modifiers: [.command, .option])

        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
            LazyView(
                SearchView()
                    .environmentObject(SearchViewModel(viewContext: context, leitner: viewModel.leitner, voiceSpeech: voiceSpeech))
            )
        }
        .keyboardShortcut("f", modifiers: [.command, .option])

        ToolbarNavigation(title: "Tags", systemImageName: "tag.square") {
            LazyView(TagView(viewModel: TagViewModel(viewContext: context, leitner: viewModel.leitner)))
        }
        .keyboardShortcut("t", modifiers: [.command, .option])

        ToolbarNavigation(title: "Statictics", systemImageName: "chart.xyaxis.line") {
            StatisticsView()
        }

        ToolbarNavigation(title: "Synonyms", systemImageName: "arrow.left.and.right.square") {
            LazyView(SynonymsView(viewModel: .init(viewContext: context, question: viewModel.leitner.allQuestions.first!)))
        }
        .keyboardShortcut("s", modifiers: [.command, .option])
    }

    @ViewBuilder var searchResult: some View {
        if viewModel.filtered.count > 0 || viewModel.searchWord.isEmpty {
            ForEach(viewModel.filtered) { suggestion in
                SearchRowView(question: suggestion, leitner: searchViewModel.leitner)
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
}

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    public var body: Content {
        build()
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
