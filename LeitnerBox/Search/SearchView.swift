//
// SearchView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI

struct SearchView: View {
    @ObservedObject
    var vm: SearchViewModel

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            List {
                ForEach(vm.filtered) { item in
                    SearchRowView(question: item, vm: vm)
                        .listRowInsets(EdgeInsets())
                }
                .onDelete(perform: vm.deleteItems)
            }
            .if(.iOS) { view in
                view.refreshable {
                    vm.viewContext.rollback()
                    vm.reload()
                }
            }
            .navigationDestination(isPresented: Binding(get: { vm.editQuestion != nil }, set: { _ in })) {
                if let editQuestion = vm.editQuestion {
                    let level = editQuestion.level ?? vm.leitner.firstLevel
                    AddOrEditQuestionView(vm: .init(viewContext: vm.viewContext, level: level!, question: editQuestion, isInEditMode: true))
                        .onDisappear {
                            vm.editQuestion = nil
                        }
                }
            }
            .animation(.easeInOut, value: vm.filtered)
            .listStyle(.plain)
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
                if vm.searchText.isEmpty == false, vm.filtered.count < 1 {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.gray.opacity(0.8))
                        Text("Nothind has found.")
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            pronunceWordsView
        }
        .animation(.easeInOut, value: vm.filtered)
        .animation(.easeInOut, value: vm.reviewStatus)
        .navigationTitle("Advance Search in \(vm.leitner.name ?? "")")
        .onAppear(perform: {
            vm.viewDidAppear()
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    NavigationLink(destination: LazyView(AddOrEditQuestionView(vm:
                        .init(
                            viewContext: vm.viewContext,
                            level: insertQuestion.level!,
                            question: insertQuestion,
                            isInEditMode: false
                        )
                    ))) {
                        Label("Add", systemImage: "plus.square")
                    }

                    Button {
                        withAnimation {
                            vm.stopReview()
                        }
                    } label: {
                        Label("Stop", systemImage: "stop.circle")
                    }
                    .disabled(vm.reviewStatus != .isPlaying)
                    .opacity(vm.reviewStatus == .isPlaying ? 1 : 0.7)

                    Button {
                        withAnimation {
                            vm.pauseReview()
                        }
                    } label: {
                        Label("Pause", systemImage: "pause.circle")
                    }
                    .disabled(vm.reviewStatus != .isPlaying)
                    .opacity(vm.reviewStatus == .isPlaying ? 1 : 0.7)

                    Button {
                        withAnimation {
                            vm.playReview()
                        }
                    } label: {
                        Label("Play", systemImage: "play.square")
                    }
                    .disabled(vm.reviewStatus == .isPlaying)
                    .opacity(vm.reviewStatus == .isPlaying ? 0.7 : 1)

                    Button {
                        withAnimation {
                            vm.playNextImmediately()
                        }
                    } label: {
                        Label("Next", systemImage: "forward.end")
                            .foregroundStyle(Color.accentColor)
                    }
                    .disabled(vm.reviewStatus != .isPlaying)
                    .opacity(vm.reviewStatus == .isPlaying ? 1 : 0.7)

                    Menu {
                        Text("Sort By")

                        ForEach(searchSorts, id: \.self) { sortItem in
                            Button {
                                withAnimation {
                                    vm.sort(sortItem.sortType)
                                }
                            } label: {
                                let favoriteCount = vm.leitner.allQuestions.filter { $0.favorite == true }.count
                                let countText = sortItem.sortType == .FAVORITE ? " (\(favoriteCount))" : ""
                                Label("\(vm.selectedSort == sortItem.sortType ? "✔︎ " : "")" + sortItem.title + countText, systemImage: sortItem.iconName)
                            }
                        }

                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
                .font(.title3)
                .symbolRenderingMode(.palette)
                .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
            }
        }
    }

    var insertQuestion: Question {
        let firstLevel = vm.leitner.firstLevel
        let question = Question(context: vm.viewContext)
        question.level = firstLevel
        return question
    }

    @State
    var heightOfReview: CGFloat = 128

    @ViewBuilder
    var pronunceWordsView: some View {
        if vm.reviewStatus == .isPlaying || vm.reviewStatus == .isPaused {
            let question = vm.lastPlayedQuestion
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    HStack {
                        if question?.favorite == true {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .foregroundColor(.accentColor)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(verbatim: question?.question ?? "")
                                .foregroundColor(.primary)
                                .font(.title.weight(.bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(verbatim: question?.answer ?? "")
                                .foregroundColor(.primary)
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(verbatim: question?.detailDescription ?? "")
                                .foregroundColor(.primary)
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(verbatim: "\(vm.reviewdCount) / \(vm.leitner.allQuestions.count)")
                                .font(.footnote.bold())
                            if let question = question {
                                QuestionTagsView(
                                    question: question,
                                    viewModel: .init(viewContext: vm.viewContext, leitner: vm.leitner),
                                    accessControls: [.showTags]
                                )
                                .frame(maxHeight: 64)
                                if question.synonyms?.count ?? 0 > 0 {
                                    QuestionSynonymsView(viewModel: .init(viewContext: vm.viewContext, question: question), accessControls: [.showSynonyms])
                                        .frame(maxHeight: 64)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .padding(.bottom, 24)
                .background(
                    Color(named: "reviewBackground")
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                        .shadow(radius: 5)
                )
            }
            .animation(.easeInOut, value: vm.lastPlayedQuestion)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    struct Preview: View {
        @ObservedObject
        var vm = SearchViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)
        var body: some View {
            SearchView(vm: vm)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
