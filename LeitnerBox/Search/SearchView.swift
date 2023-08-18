//
// SearchView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct SearchView: View {
    let container: ObjectsContainer
    @EnvironmentObject var viewModel: SearchViewModel
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    private var searchedQuestions: [Question] { viewModel.searchedQuestions }

    var body: some View {
        List {
            ForEach(searchedQuestions.count > 0 ? searchedQuestions : viewModel.questions) { question in
                NormalQuestionRow(question: question)
                    .listRowInsets(EdgeInsets())
                    .onAppear {
                        if question == viewModel.questions.last {
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
        .environmentObject(container)
        .animation(.easeInOut, value: viewModel.questions.count)
        .animation(.easeInOut, value: searchedQuestions.count)
        .animation(.easeInOut, value: viewModel.reviewStatus)
        .navigationTitle("Advance Search in \(viewModel.leitner.name ?? "")")
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
            if viewModel.searchText.isEmpty == false, searchedQuestions.count < 1 {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.gray.opacity(0.8))
                    Text("Nothind has found.")
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
        }
        .overlay {
            PronunceWordsView()
                .environmentObject(container)
        }
        .onAppear {
            viewModel.viewDidAppear()
            viewModel.resumeSpeaking()
        }
        .onDisappear {
            viewModel.pauseSpeaking()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                MutableSearchViewToolbar(container: container, viewModel: viewModel)
            }
        }
    }
}

struct MutableSearchViewToolbar: View {
    let container: ObjectsContainer
    @State var favoriteCount: Int = 0
    let viewModel: SearchViewModel
    @State var reviewStatus: ReviewStatus = .unInitialized

    var body: some View {
        ToolbarNavigation(title: "Add Question", systemImageName: "plus.square") {
            AddOrEditQuestionView()
                .environmentObject(container)
        }

        Button {
            withAnimation {
                viewModel.playReview()
                reviewStatus = viewModel.reviewStatus
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Play", systemImageName: "play.square")
        }
        .toobarNavgationButtonStyle()
        .disabled(reviewStatus == .isPlaying)
        .opacity(reviewStatus == .isPlaying ? 0.7 : 1)
        .scaleEffect(x: reviewStatus == .isPlaying ? 0.8 : 1.0, y: reviewStatus == .isPlaying ? 0.8 : 1.0)
        .keyboardShortcut("p", modifiers: [.command, .option])

        Button {
            withAnimation {
                viewModel.stopReview()
                reviewStatus = viewModel.reviewStatus
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Stop", systemImageName: "stop.circle")
        }
        .toobarNavgationButtonStyle()
        .disabled(reviewStatus != .isPlaying)
        .opacity(reviewStatus == .isPlaying ? 1 : 0.7)
        .scaleEffect(x: (reviewStatus == .unInitialized || reviewStatus == .isPaused) ? 0.8 : 1.0, y: (reviewStatus == .unInitialized || reviewStatus == .isPaused) ? 0.8 : 1.0)
        .keyboardShortcut("s", modifiers: [.command, .option])

        Button {
            withAnimation {
                viewModel.pauseReview()
                reviewStatus = viewModel.reviewStatus
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Pause", systemImageName: "pause.circle")
        }
        .toobarNavgationButtonStyle()
        .disabled(reviewStatus != .isPlaying)
        .opacity(reviewStatus == .isPlaying ? 1 : 0.7)
        .scaleEffect(x: reviewStatus == .isPlaying ? 1.0 : 0.8, y: reviewStatus == .isPlaying ? 1.0 : 0.8)
        .keyboardShortcut("p", modifiers: [.command, .option])

        Button {
            withAnimation {
                viewModel.playNextImmediately()
                reviewStatus = viewModel.reviewStatus
            }
        } label: {
            IconButtonKeyboardShortcut(title: "Next", systemImageName: "forward.end")
                .foregroundStyle(Color.accentColor)
        }
        .toobarNavgationButtonStyle()
        .disabled(reviewStatus != .isPlaying)
        .opacity(reviewStatus == .isPlaying ? 1 : 0.7)
        .scaleEffect(x: reviewStatus == .isPlaying ? 1.0 : 0.8, y: reviewStatus == .isPlaying ? 1.0 : 0.8, anchor: .center)
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
        .onAppear {
            favoriteCount = Leitner.fetchFavCount(context: viewModel.viewContext, leitnerId: viewModel.leitner.id)
        }
    }
}

struct PronunceWordsView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    private var searchVM: SearchViewModel { objVM.searchVM }

    var body: some View {
        if searchVM.reviewStatus == .isPlaying || searchVM.reviewStatus == .isPaused {
            let question = searchVM.lastPlayedQuestion
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
                            Text(verbatim: "\(searchVM.reviewdCount) / \(Leitner.fetchLeitnerQuestionsCount(context: context, leitnerId: searchVM.leitner.id))")
                                .font(.footnote.bold())
                            if let question {
                                QuestionTagList(tags: question.tagsArray ?? [])
                                    .environmentObject(question)
                                    .frame(maxHeight: 64)
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
            .animation(.easeInOut, value: searchVM.lastPlayedQuestion)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    struct Preview: View {
        static let context = PersistenceController.shared.viewContext
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        @StateObject var viewModel = SearchViewModel(
            viewContext: Preview.context,
            leitner: Preview.leitner,
            voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice
        )

        var body: some View {
            SearchView(container: ObjectsContainer(context: Preview.context, leitner: Preview.leitner, leitnerVM: LeitnerViewModel(viewContext: Preview.context)))
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
