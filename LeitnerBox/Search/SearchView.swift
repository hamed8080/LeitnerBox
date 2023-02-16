//
// SearchView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @State var favoriteCount: Int = 0

    var body: some View {
        List {
            ForEach(objVM.searchVM.searchedQuestions.count > 0 ? objVM.searchVM.searchedQuestions : objVM.searchVM.questions) { question in
                NormalQuestionRow(question: question)
                    .listRowInsets(EdgeInsets())
                    .onAppear {
                        if question == objVM.searchVM.questions.last {
                            objVM.searchVM.fetchMoreQuestion()
                        }
                    }
            }
            .onDelete(perform: objVM.searchVM.deleteItems)
        }
        .if(.iOS) { view in
            view.refreshable {
                context.rollback()
                objVM.searchVM.reload()
            }
        }
        .animation(.easeInOut, value: objVM.searchVM.questions.count)
        .animation(.easeInOut, value: objVM.searchVM.searchedQuestions.count)
        .animation(.easeInOut, value: objVM.searchVM.reviewStatus)
        .navigationTitle("Advance Search in \(objVM.searchVM.leitner.name ?? "")")
        .listStyle(.plain)
        .searchable(text: $objVM.searchVM.searchText, placement: .navigationBarDrawer, prompt: "Search inside leitner...") {
            if objVM.searchVM.searchText.isEmpty == false, objVM.searchVM.searchedQuestions.count < 1 {
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
        }
        .onAppear {
            objVM.searchVM.viewDidAppear()
            objVM.searchVM.resumeSpeaking()
            favoriteCount = Leitner.fetchFavCount(context: context, leitnerId: objVM.searchVM.leitner.id)
        }
        .onDisappear {
            objVM.searchVM.pauseSpeaking()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ToolbarNavigation(title: "Add Question", systemImageName: "plus.square") {
                    AddOrEditQuestionView()
                        .environmentObject(objVM)
                }

                Button {
                    withAnimation {
                        objVM.searchVM.stopReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Stop", systemImageName: "stop.circle")
                }
                .toobarNavgationButtonStyle()
                .disabled(objVM.searchVM.reviewStatus != .isPlaying)
                .opacity(objVM.searchVM.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("s", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        objVM.searchVM.pauseReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Pause", systemImageName: "pause.circle")
                }
                .toobarNavgationButtonStyle()
                .disabled(objVM.searchVM.reviewStatus != .isPlaying)
                .opacity(objVM.searchVM.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("p", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        objVM.searchVM.playReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Play", systemImageName: "play.square")
                }
                .toobarNavgationButtonStyle()
                .disabled(objVM.searchVM.reviewStatus == .isPlaying)
                .opacity(objVM.searchVM.reviewStatus == .isPlaying ? 0.7 : 1)
                .keyboardShortcut("p", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        objVM.searchVM.playNextImmediately()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Next", systemImageName: "forward.end")
                        .foregroundStyle(Color.accentColor)
                }
                .toobarNavgationButtonStyle()
                .disabled(objVM.searchVM.reviewStatus != .isPlaying)
                .opacity(objVM.searchVM.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("n", modifiers: [.command, .option])

                Menu {
                    Text("Sort By")

                    ForEach(searchSorts, id: \.self) { sortItem in
                        Button {
                            withAnimation {
                                objVM.searchVM.sort(sortItem.sortType)
                            }
                        } label: {
                            let countText = sortItem.sortType == .favorite ? " (\(favoriteCount))" : ""
                            Label("\(objVM.searchVM.selectedSort == sortItem.sortType ? "✔︎ " : "")" + sortItem.title + countText, systemImage: sortItem.iconName)
                        }
                    }

                    Menu {
                        ForEach(objVM.searchVM.sortedTags, id: \.self) { tag in
                            Button {
                                withAnimation {
                                    objVM.searchVM.sort(.date, tag)
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
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
        if objVM.searchVM.reviewStatus == .isPlaying || objVM.searchVM.reviewStatus == .isPaused {
            let question = objVM.searchVM.lastPlayedQuestion
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
                            Text(verbatim: "\(objVM.searchVM.reviewdCount) / \(Leitner.fetchLeitnerQuestionsCount(context: context, leitnerId: objVM.searchVM.leitner.id))")
                                .font(.footnote.bold())
                            if let question {
                                QuestionTagList(tags: question.tagsArray ?? [])
                                    .environmentObject(question)
                                    .frame(maxHeight: 64)
//                                if let synonyms = question.synonyms?.allObjects as? [Synonym], synonyms.count > 0 {
//                                    QuestionSynonymList(synonyms: synonyms, onClick: { _ in }, onLongClick: { _ in })
//                                        .frame(maxHeight: 64)
//                                }
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
            .animation(.easeInOut, value: objVM.searchVM.lastPlayedQuestion)
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
