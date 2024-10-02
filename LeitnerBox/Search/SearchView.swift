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
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        compatibleScrollView
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
            .onChange(of: scenePhase) { newValue in
                viewModel.onScenePhaseChanged(newValue)
            }
    }

    @ViewBuilder
    private var compatibleScrollView: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            iOS17ScrollView
        } else {
            iOS16ScrollView
        }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private var iOS17ScrollView: some View {
        ScrollView {
            scrollContent
                .scrollTargetLayout()
        }
        .scrollPosition(id: $viewModel.scrollToId, anchor: .top)
    }

    private var iOS16ScrollView: some View {
        ScrollViewReader { reader in
            ScrollView {
                scrollContent
                    .onChange(of: viewModel.scrollToId) { newValue in
                        withAnimation {
                            reader.scrollTo(newValue, anchor: .top)
                        }
                    }
            }
        }
    }

    private var scrollContent: some View {
        LazyVStack {
            ForEach(searchedQuestions.count > 0 ? searchedQuestions : viewModel.questions) { question in
                NormalQuestionRow(question: question)
                    .id(question.question)
                    .listRowInsets(EdgeInsets())
                    .background(viewModel.scrollToId == question.question ? Color.accentColor.opacity(0.5) : Color.clear)
                    .onAppear {
                        if question == viewModel.questions.last {
                            viewModel.fetchMoreQuestion()
                        }
                    }
            }
            .onDelete(perform: viewModel.deleteItems)
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
        .tint(Color("AccentColor"))
        .onAppear {
            favoriteCount = Leitner.fetchFavCount(context: viewModel.viewContext, leitnerId: viewModel.leitner.id)
        }
        .onReceive(container.searchVM.objectWillChange) { _ in
            if reviewStatus != viewModel.reviewStatus {
                self.reviewStatus = viewModel.reviewStatus
            }
        }
    }
}

struct PronunceWordsView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    private var question: Question? { viewModel.lastPlayedQuestion }

    var body: some View {
        if viewModel.reviewStatus == .isPlaying || viewModel.reviewStatus == .isPaused {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    ScrollView {
                        HStack {
                            starView
                            VStack(alignment: .leading, spacing: 8) {
                                questionView
                                answerView
                                descriptionView
                                countView
                                tagsView
                            }
                        }
                        .padding([.top, .leading])
                    }
                    .frame(maxHeight: 256)
                    .padding([.leading, .trailing])
                    Spacer()
                }
                .background(.thinMaterial)
                .cornerRadius(24, corners: [.topLeft, .topRight])
            }
            .animation(.easeInOut, value: viewModel.lastPlayedQuestion)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }

    @ViewBuilder
    private var starView: some View {
        if question?.favorite == true {
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(8)
                .foregroundColor(.accentColor)
        }
    }

    @ViewBuilder
    private var questionView: some View {
        Button {
            withAnimation {
                viewModel.scrollToId = question?.question
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    viewModel.scrollToId = nil
                }
            }
        } label: {
            Text(verbatim: question?.question ?? "")
                .foregroundColor(.primary)
                .font(.title.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var answerView: some View {
        if let answer = question?.answer, !answer.isEmpty {
            Text(verbatim: answer)
                .foregroundColor(.primary)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = question?.detailDescription, !description.isEmpty {
            Text(verbatim: description)
                .foregroundColor(.primary)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var countView: some View {
        Text(verbatim: "\(viewModel.reviewdCount) / \(Leitner.fetchLeitnerQuestionsCount(context: context, leitnerId: viewModel.leitner.id))")
            .font(.footnote.bold())
    }

    @ViewBuilder
    private var tagsView: some View {
        if let question {
            QuestionTagList(tags: question.tagsArray ?? [])
                .environmentObject(question)
                .frame(maxHeight: 64)
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
