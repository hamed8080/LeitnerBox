//
// SearchView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @State var favoriteCount: Int = 0

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.searchedQuestions.count > 0 ? viewModel.searchedQuestions : viewModel.questions) { item in
                    SearchRowView(question: item, leitner: viewModel.leitner)
                        .listRowInsets(EdgeInsets())
                        .onAppear {
                            if item == viewModel.questions.last {
                                viewModel.fetchMoreQuestion()
                            }
                        }
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
            .listStyle(.plain)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
                if viewModel.searchText.isEmpty == false, viewModel.searchedQuestions.count < 1 {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.gray.opacity(0.8))
                        Text("Nothind has found.")
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            PronunceWordsView()
        }
        .animation(.easeInOut, value: viewModel.questions.count)
        .animation(.easeInOut, value: viewModel.searchedQuestions.count)
        .animation(.easeInOut, value: viewModel.reviewStatus)
        .navigationTitle("Advance Search in \(viewModel.leitner.name ?? "")")
        .onAppear {
            viewModel.viewDidAppear()
            viewModel.resumeSpeaking()
            favoriteCount = Leitner.fetchFavCount(context: context, leitnerId: viewModel.leitner.id)
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
                            let countText = sortItem.sortType == .favorite ? " (\(favoriteCount))" : ""
                            Label("\(viewModel.selectedSort == sortItem.sortType ? "✔︎ " : "")" + sortItem.title + countText, systemImage: sortItem.iconName)
                        }
                    }

                    Menu {
                        ForEach(viewModel.sortedTags, id: \.self) { tag in
                            Button {
                                withAnimation {
                                    viewModel.sort(.date, tag)
                                }
                            } label: {
                                Text(tag.name ?? "")
                            }
                        }
                    } label: {
                        Text("Sort By Tag")
                    }

                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .toobarNavgationButtonStyle()
            }
        }
    }
}

struct PronunceWordsView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
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
                            Text(verbatim: "\(viewModel.reviewdCount) / \(Leitner.fetchLeitnerQuestionsCount(context: context, leitnerId: viewModel.leitner.id))")
                                .font(.footnote.bold())
                            if let question {
                                QuestionTagsView(
                                    viewModel: .init(viewContext: context, leitner: viewModel.leitner),
                                    accessControls: [.showTags]
                                )
                                .environmentObject(question)
                                .frame(maxHeight: 64)
                                if question.synonyms?.count ?? 0 > 0 {
                                    QuestionSynonymsView(accessControls: [.showSynonyms])
                                        .environmentObject(SynonymViewModel(viewContext: context, leitner: viewModel.leitner, baseQuestion: question))
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
        static let context = PersistenceController.shared.viewContext
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        @StateObject var viewModel = SearchViewModel(
            viewContext: Preview.context,
            leitner: Preview.leitner,
            voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice
        )

        var body: some View {
            SearchView()
                .environment(\.managedObjectContext, Preview.context)
                .environmentObject(LeitnerViewModel(viewContext: Preview.context))
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
