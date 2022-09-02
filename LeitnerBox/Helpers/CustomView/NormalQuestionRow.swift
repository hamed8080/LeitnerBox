//
// NormalQuestionRow.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import SwiftUI

struct NormalQuestionRow: View {
    @ObservedObject
    var question: Question

    @ObservedObject
    var tagsViewModel: TagViewModel

    @ObservedObject
    var searchViewModel: SearchViewModel

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.dynamicTypeSize)
    var typeSize

    var tagCompletion: (() -> Void)?

    var ac: [AccessControls]

    public init(question: Question, tagsViewModel: TagViewModel, searchViewModel: SearchViewModel? = nil, accessControls: [AccessControls] = AccessControls.full, tagCompletion: (() -> Void)? = nil) {
        self.question = question
        self.tagsViewModel = tagsViewModel
        self.searchViewModel = searchViewModel ?? SearchViewModel(viewContext: tagsViewModel.viewContext, leitner: tagsViewModel.leitner)
        self.tagCompletion = tagCompletion
        ac = accessControls
    }

    var body: some View {
        HStack {
            if sizeClass == .regular, typeSize == .large {
                ipadView
            } else {
                iphoneView
            }
        }
    }

    var ipadView: some View {
        VStack(alignment: .leading, spacing: 4) {
            questionAndAnswer
                .padding(.top, 8)
                .padding([.leading, .trailing])
            HStack {
                levelAndAvailibility
                Spacer()
                completed
                controls
            }
            .padding([.leading, .trailing])

            QuestionTagsView(
                question: question,
                viewModel: tagsViewModel,
                addPadding: true,
                accessControls: ac
            ) {
                tagCompletion?()
            }
        }
    }

    var iphoneView: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                questionAndAnswer
                levelAndAvailibility
                HStack {
                    completed
                    Spacer()
                    controls
                }
            }.padding()

            QuestionTagsView(
                question: question,
                viewModel: tagsViewModel,
                addPadding: true,
                accessControls: ac
            ) {
                tagCompletion?()
            }
        }
    }

    var levelAndAvailibility: some View {
        HStack {
            Text(verbatim: "LEVEL: \(question.level?.level ?? 0)")
                .foregroundColor(.blue)
                .font(.footnote.bold())

            Text(question.remainDays)
                .foregroundColor(.gray)
                .font(.footnote.bold())
        }
    }

    @ViewBuilder
    var questionAndAnswer: some View {
        Text(question.question ?? "")
            .font(.title2.bold())
        if let answer = question.answer, !answer.isEmpty {
            Text(answer.uppercased())
                .foregroundColor(.gray)
                .font(.headline.bold())
        }

        if let detailDescription = question.detailDescription, !detailDescription.isEmpty {
            Text(detailDescription.uppercased())
                .foregroundColor(.gray)
                .font(.headline.bold())
        }
    }

    @ViewBuilder
    var completed: some View {
        if question.completed {
            Text("COMPLETED")
                .foregroundColor(.blue)
                .font(.footnote.bold())
        }
    }

    @ViewBuilder
    var controls: some View {
        if ac.contains(.trailingControls) {
            let padding: CGFloat = sizeClass == .compact ? 4 : 8
            HStack(spacing: padding) {
                let controlSize: CGFloat = 24
                if ac.contains(.microphone) {
                    Button {
                        searchViewModel.pronounceOnce(question)
                    } label: {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: controlSize, height: controlSize)
                            .padding(padding)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.borderless)
                }

                if ac.contains(.favorite) {
                    Button {
                        withAnimation {
                            searchViewModel.toggleFavorite(question)
                        }
                    } label: {
                        Image(systemName: question.favorite ? "star.fill" : "star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: controlSize, height: controlSize)
                            .padding(padding)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.borderless)
                }

                if ac.contains(.more) {
                    Menu {
                        if ac.contains(.delete) {
                            Button(role: .destructive) {
                                withAnimation {
                                    searchViewModel.delete(question)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Divider()
                        }

                        if ac.contains(.edit) {
                            Button {
                                searchViewModel.editQuestion = question
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }

                        if ac.contains(.copy) {
                            Button {
                                UIPasteboard.general.string = [question.question, question.answer, question.detailDescription]
                                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                                    .joined(separator: "\n")
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }

                        if ac.contains(.reset) {
                            Button {
                                withAnimation {
                                    searchViewModel.resetToFirstLevel(question)
                                }
                            } label: {
                                Label("Reset to first level", systemImage: "goforward")
                            }
                        }

                        if ac.contains(.completed) {
                            Button {
                                withAnimation {
                                    searchViewModel.complete(question)
                                }
                            } label: {
                                Label("Mark as completed", systemImage: "tray.full")
                            }

                            Divider()
                        }

                        if ac.contains(.move) {
                            Menu("Move") {
                                let vm = LeitnerViewModel(viewContext: PersistenceController.shared.container.viewContext)
                                ForEach(vm.leitners) { leitner in
                                    Button {
                                        withAnimation {
                                            self.searchViewModel.moveQuestionTo(question, leitner: leitner)
                                        }
                                    } label: {
                                        Label("\(leitner.name ?? "")", systemImage: "folder")
                                    }
                                }
                            }
                        }

                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: controlSize, height: controlSize)
                            .padding(padding)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .overlay(
                editNavigation
            )
        }
    }

    @ViewBuilder
    var editNavigation: some View {
        let binding = Binding(
            get: { searchViewModel.editQuestion != nil },
            set: { _ in }
        )

        if let question = searchViewModel.editQuestion {
            NavigationLink(isActive: binding) {
                let level = question.level ?? searchViewModel.leitner.firstLevel
                AddOrEditQuestionView(vm: .init(viewContext: searchViewModel.viewContext, level: level!, question: question, isInEditMode: true))
                    .onDisappear {
                        searchViewModel.editQuestion = nil
                    }
            } label: {
                EmptyView()
                    .frame(width: 0, height: 0)
            }
            .hidden()
        }
    }
}

struct NormalQuestionRow_Previews: PreviewProvider {
    static var previews: some View {
        let leitner = LeitnerView_Previews.leitner
        let question = leitner.levels.filter { $0.level == 1 }.first?.allQuestions.first as? Question
        let tagVM = TagViewModel(viewContext: PersistenceController.previewVC, leitner: leitner)
        let searchVM = SearchViewModel(viewContext: PersistenceController.previewVC, leitner: leitner)
        NormalQuestionRow(question: question!, tagsViewModel: tagVM, searchViewModel: searchVM)
    }
}
