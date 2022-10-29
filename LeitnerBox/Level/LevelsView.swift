//
// LevelsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI
import AVFoundation

struct LevelsView: View {
    @EnvironmentObject
    var vm: LevelsViewModel

    @EnvironmentObject
    var searchViewModel: SearchViewModel

    @Environment(\.avSpeechSynthesisVoice)
    var voiceSpeech: AVSpeechSynthesisVoice

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var body: some View {
        ZStack {
            List {
                if vm.filtered.count >= 1 {
                    searchResult
                } else {
                    header
                    ForEach(vm.levels) { level in
                        LevelRow()
                            .environmentObject(level)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $vm.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...")
            .if(.iOS) { view in
                view.refreshable {
                    context.rollback()
                    vm.load()
                }
            }
            .navigationDestination(isPresented: Binding(get: { searchViewModel.editQuestion != nil }, set: { _ in })) {
                if let editQuestion = searchViewModel.editQuestion {
                    let level = editQuestion.level ?? searchViewModel.leitner.firstLevel
                    AddOrEditQuestionView(
                        vm: .init(viewContext: context, level: level!, question: editQuestion, isInEditMode: true),
                        synonymsVM: SynonymViewModel(viewContext: context, question: editQuestion),
                        tagVM: TagViewModel(viewContext: context, leitner: level!.leitner!)
                    )
                        .onDisappear {
                            searchViewModel.editQuestion = nil
                        }
                }
            }
        }
        .animation(.easeInOut, value: vm.searchWord)
        .navigationTitle(vm.levels.first?.leitner?.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbars
            }
        }
        .customDialog(isShowing: $vm.showDaysAfterDialog) {
            daysToRecommendDialogView
        }
    }

    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            let totalCount = vm.levels.map { $0.questions?.count ?? 0 }.reduce(0,+)

            let completedCount = vm.levels.map { level in
                let completedCount = level.allQuestions.filter {
                    $0.completed == true
                }
                return completedCount.count
            }.reduce(0,+)

            let reviewableCount = vm.levels.map { level in
                level.reviewableCountInsideLevel
            }.reduce(0,+)

            let text = "\(totalCount) total, \(completedCount) completed, \(reviewableCount) reviewable".uppercased()

            Text(text)
                .font(.footnote.weight(.bold))
                .foregroundColor(.gray)
        }
        .listRowSeparator(.hidden)
    }

    var insertQuestion: Question {
        let question = Question(context: context)
        question.level = vm.leitner.firstLevel
        return question
    }

    @ViewBuilder
    var toolbars: some View {
        ToolbarNavigation(title: "Add Item", systemImageName: "plus.square") {
            LazyView(
                AddOrEditQuestionView(
                    vm: .init(viewContext: context, level: insertQuestion.level!, question: insertQuestion, isInEditMode: false),
                    synonymsVM: SynonymViewModel(viewContext: context, question: insertQuestion),
                    tagVM: TagViewModel(viewContext: context, leitner: vm.leitner)
                )
            )
        }
        .keyboardShortcut("a", modifiers: [.command, .option])

        ToolbarNavigation(title: "Search View", systemImageName: "square.text.square") {
            LazyView(
                SearchView()
                    .environmentObject(SearchViewModel(viewContext: context, leitner: vm.leitner, voiceSpeech: voiceSpeech))
            )
        }
        .keyboardShortcut("f", modifiers: [.command, .option])

        ToolbarNavigation(title: "Tags", systemImageName: "tag.square") {
            LazyView(TagView(vm: TagViewModel(viewContext: context, leitner: vm.leitner)))
        }
        .keyboardShortcut("t", modifiers: [.command, .option])

        ToolbarNavigation(title: "Statictics", systemImageName: "chart.xyaxis.line") {
            StatisticsView()
        }

        ToolbarNavigation(title: "Synonyms", systemImageName: "arrow.left.and.right.square") {
            LazyView(SynonymsView(viewModel: .init(viewContext: context, question: vm.leitner.allQuestions.first!)))
        }
        .keyboardShortcut("s", modifiers: [.command, .option])
    }

    @ViewBuilder
    var searchResult: some View {
        if vm.filtered.count > 0 || vm.searchWord.isEmpty {
            ForEach(vm.filtered) { suggestion in
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

    var daysToRecommendDialogView: some View {
        VStack(spacing: 24) {
            Text(verbatim: "Level \(vm.selectedLevel?.level ?? 0)")
                .foregroundColor(.accentColor)
                .font(.title2.bold())

            Stepper(value: $vm.daysToRecommend, in: 1 ... 365, step: 1) {
                Text(verbatim: "Days to recommend: \(vm.daysToRecommend)")
            }.onChange(of: vm.daysToRecommend) { _ in
                vm.saveDaysToRecommned()
            }

            Button {
                vm.showDaysAfterDialog.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("Close")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
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
        @StateObject
        var vm = LevelsViewModel(viewContext: PersistenceController.previewVC, leitner: LeitnerView_Previews.leitner)

        @StateObject
        var searchViewModel = SearchViewModel(viewContext: PersistenceController.previewVC, leitner: LeitnerView_Previews.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)

        var body: some View {
            LevelsView()
                .environmentObject(vm)
                .environmentObject(searchViewModel)
                .environment(\.managedObjectContext, PersistenceController.previewVC)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
