//
// SearchView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject
    var viewModel: SearchViewModel

    @Environment(\.colorScheme) var colorScheme

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.filtered) { item in
                    SearchRowView(question: item, leitner: viewModel.leitner)
                        .listRowInsets(EdgeInsets())
                }
                .onDelete(perform: viewModel.deleteItems)
            }
            .if(.iOS) { view in
                view.refreshable {
                    context.rollback()
                    viewModel.reload()
                }
            }
            .navigationDestination(isPresented: Binding(get: { viewModel.editQuestion != nil }, set: { _ in })) {
                if let editQuestion = viewModel.editQuestion {
                    AddOrEditQuestionView(viewModel: .init(viewContext: context, leitner: viewModel.leitner, question: editQuestion))
                        .onDisappear {
                            viewModel.editQuestion = nil
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.filtered)
            .listStyle(.plain)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
                if viewModel.searchText.isEmpty == false, viewModel.filtered.count < 1 {
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
        .animation(.easeInOut, value: viewModel.filtered)
        .animation(.easeInOut, value: viewModel.reviewStatus)
        .navigationTitle("Advance Search in \(viewModel.leitner.name ?? "")")
        .onAppear {
            viewModel.viewDidAppear()
            viewModel.resumeSpeaking()
        }
        .onDisappear {
            viewModel.pauseSpeaking()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ToolbarNavigation(title: "Add Question", systemImageName: "plus.square") {
                    LazyView(
                        AddOrEditQuestionView(viewModel: .init(viewContext: context, leitner: viewModel.leitner))
                    )
                }

                Button {
                    withAnimation {
                        viewModel.stopReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Stop", systemImageName: "stop.circle")
                }
                .toobarNavgationButtonStyle()
                .disabled(viewModel.reviewStatus != .isPlaying)
                .opacity(viewModel.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("s", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        viewModel.pauseReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Pause", systemImageName: "pause.circle")
                }
                .toobarNavgationButtonStyle()
                .disabled(viewModel.reviewStatus != .isPlaying)
                .opacity(viewModel.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("p", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        viewModel.playReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Play", systemImageName: "play.square")
                }
                .toobarNavgationButtonStyle()
                .disabled(viewModel.reviewStatus == .isPlaying)
                .opacity(viewModel.reviewStatus == .isPlaying ? 0.7 : 1)
                .keyboardShortcut("p", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        viewModel.playNextImmediately()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Next", systemImageName: "forward.end")
                        .foregroundStyle(Color.accentColor)
                }
                .toobarNavgationButtonStyle()
                .disabled(viewModel.reviewStatus != .isPlaying)
                .opacity(viewModel.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("n", modifiers: [.command, .option])

                Menu {
                    Text("Sort By")

                    ForEach(searchSorts, id: \.self) { sortItem in
                        Button {
                            withAnimation {
                                viewModel.sort(sortItem.sortType)
                            }
                        } label: {
                            let favoriteCount = viewModel.leitner.allQuestions.filter { $0.favorite == true }.count
                            let countText = sortItem.sortType == .favorite ? " (\(favoriteCount))" : ""
                            Label("\(viewModel.selectedSort == sortItem.sortType ? "✔︎ " : "")" + sortItem.title + countText, systemImage: sortItem.iconName)
                        }
                    }

                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .toobarNavgationButtonStyle()
            }
        }
    }

    @State
    var heightOfReview: CGFloat = 128

    @ViewBuilder
    var pronunceWordsView: some View {
        if viewModel.reviewStatus == .isPlaying || viewModel.reviewStatus == .isPaused {
            let question = viewModel.lastPlayedQuestion
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
                            if let answer = question?.answer, !answer.isEmpty {
                                Text(verbatim: answer)
                                    .foregroundColor(.primary)
                                    .font(.body.weight(.medium))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let description = question?.detailDescription, !description.isEmpty {
                                Text(verbatim: description)
                                    .foregroundColor(.primary)
                                    .font(.body.weight(.medium))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(verbatim: "\(viewModel.reviewdCount) / \(viewModel.leitner.allQuestions.count)")
                                .font(.footnote.bold())
                            if let question = question {
                                QuestionTagsView(
                                    viewModel: .init(viewContext: context, leitner: viewModel.leitner),
                                    accessControls: [.showTags]
                                )
                                .environmentObject(question)
                                .frame(maxHeight: 64)
                                if question.synonyms?.count ?? 0 > 0 {
                                    QuestionSynonymsView(accessControls: [.showSynonyms])
                                        .environmentObject(SynonymViewModel(viewContext: context, question: question))
                                        .frame(maxHeight: 64)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .padding(.bottom, 24)
                .background(.thinMaterial)
                .cornerRadius(24, corners: [.topLeft, .topRight])
            }
            .animation(.easeInOut, value: viewModel.lastPlayedQuestion)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject
        var viewModel = SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: LeitnerView_Previews.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        var body: some View {
            SearchView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
                .environmentObject(viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
