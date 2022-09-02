//
// LevelsView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI

struct LevelsView: View {
    @ObservedObject
    var vm: LevelsViewModel

    @ObservedObject
    var searchViewModel: SearchViewModel

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            List {
                if vm.filtered.count >= 1 {
                    searchResult
                } else {
                    header
                    ForEach(vm.levels) { level in
                        LevelRow(vm: vm, level: level)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $vm.searchWord, placement: .navigationBarDrawer, prompt: "Search inside leitner...")
            .if(.iOS) { view in
                view.refreshable {
                    vm.viewContext.rollback()
                    vm.load()
                }
            }
            .navigationDestination(isPresented: Binding(get: { searchViewModel.editQuestion != nil }, set: { _ in })) {
                if let editQuestion = searchViewModel.editQuestion {
                    let level = editQuestion.level ?? searchViewModel.leitner.firstLevel
                    AddOrEditQuestionView(vm: .init(viewContext: vm.viewContext, level: level!, question: editQuestion, isInEditMode: true))
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
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
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
        let question = Question(context: vm.viewContext)
        question.level = vm.leitner.firstLevel
        return question
    }

    @ViewBuilder
    var toolbars: some View {
        NavigationLink(destination: LazyView(AddOrEditQuestionView(vm: .init(viewContext: vm.viewContext, level: insertQuestion.level!, question: insertQuestion, isInEditMode: false)))) {
            Label("Add Item", systemImage: "plus.square")
        }

        NavigationLink {
            SearchView(vm: SearchViewModel(viewContext: vm.viewContext, leitner: vm.leitner))
        } label: {
            Label("Search View", systemImage: "list.bullet.rectangle.portrait")
        }

        NavigationLink {
            TagView(vm: TagViewModel(viewContext: vm.viewContext, leitner: vm.leitner))
        } label: {
            Label("Tags", systemImage: "tag.square")
        }

        NavigationLink {
            StatisticsView(vm: .init())
        } label: {
            Label("Statictics", systemImage: "chart.xyaxis.line")
        }

        NavigationLink(destination: LazyView(SynonymsView(viewModel: .init(viewContext: vm.viewContext, question: vm.leitner.allQuestions.first!)))) {
            Label("Synonyms", systemImage: "arrow.left.and.right.square")
        }
    }

    @ViewBuilder
    var searchResult: some View {
        if vm.filtered.count > 0 || vm.searchWord.isEmpty {
            ForEach(vm.filtered) { suggestion in
                SearchRowView(question: suggestion, vm: searchViewModel)
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
        @ObservedObject
        var vm = LevelsViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)

        @ObservedObject
        var searchViewModel = SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)

        var body: some View {
            LevelsView(vm: vm, searchViewModel: searchViewModel)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
