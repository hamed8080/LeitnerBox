//
// SearchView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject
    var vm: SearchViewModel

    @Environment(\.colorScheme) var colorScheme

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var body: some View {
        ZStack {
            List {
                ForEach(vm.filtered) { item in
                    SearchRowView(question: item, leitner: vm.leitner)
                        .listRowInsets(EdgeInsets())
                }
                .onDelete(perform: vm.deleteItems)
            }
            .if(.iOS) { view in
                view.refreshable {
                    context.rollback()
                    vm.reload()
                }
            }
            .navigationDestination(isPresented: Binding(get: { vm.editQuestion != nil }, set: { _ in })) {
                if let editQuestion = vm.editQuestion {
                    AddOrEditQuestionView(vm: .init(viewContext: context, leitner: vm.leitner, question: editQuestion))
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
        .onAppear {
            vm.viewDidAppear()
            vm.resumeSpeaking()
        }
        .onDisappear {
            vm.pauseSpeaking()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ToolbarNavigation(title: "Add Question", systemImageName: "plus.square") {
                    LazyView(
                        AddOrEditQuestionView(vm: .init(viewContext: context, leitner: vm.leitner))
                    )
                }

                Button {
                    withAnimation {
                        vm.stopReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Stop", systemImageName: "stop.circle")
                }
                .toobarNavgationButtonStyle()
                .disabled(vm.reviewStatus != .isPlaying)
                .opacity(vm.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("s", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        vm.pauseReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Pause", systemImageName: "pause.circle")
                }
                .toobarNavgationButtonStyle()
                .disabled(vm.reviewStatus != .isPlaying)
                .opacity(vm.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("p", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        vm.playReview()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Play", systemImageName: "play.square")
                }
                .toobarNavgationButtonStyle()
                .disabled(vm.reviewStatus == .isPlaying)
                .opacity(vm.reviewStatus == .isPlaying ? 0.7 : 1)
                .keyboardShortcut("p", modifiers: [.command, .option])

                Button {
                    withAnimation {
                        vm.playNextImmediately()
                    }
                } label: {
                    IconButtonKeyboardShortcut(title: "Next", systemImageName: "forward.end")
                        .foregroundStyle(Color.accentColor)
                }
                .toobarNavgationButtonStyle()
                .disabled(vm.reviewStatus != .isPlaying)
                .opacity(vm.reviewStatus == .isPlaying ? 1 : 0.7)
                .keyboardShortcut("n", modifiers: [.command, .option])

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
                .toobarNavgationButtonStyle()
            }
        }
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
                            Text(verbatim: "\(vm.reviewdCount) / \(vm.leitner.allQuestions.count)")
                                .font(.footnote.bold())
                            if let question = question {
                                QuestionTagsView(
                                    viewModel: .init(viewContext: context, leitner: vm.leitner),
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
            .animation(.easeInOut, value: vm.lastPlayedQuestion)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject
        var vm = SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: LeitnerView_Previews.leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        var body: some View {
            SearchView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environment(\.avSpeechSynthesisVoice, EnvironmentValues().avSpeechSynthesisVoice)
                .environmentObject(vm)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
