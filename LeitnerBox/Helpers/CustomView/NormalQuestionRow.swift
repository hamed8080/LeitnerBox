//
// NormalQuestionRow.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct NormalQuestionRow: View {
    @StateObject var question: Question
    @StateObject var tagsViewModel: TagViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var leitnersVM: LeitnerViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var aceessControls: [AccessControls] = {
        var aceessControls = AccessControls.full
        aceessControls.append(.saveDirectly)
        return aceessControls
    }()

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
                viewModel: tagsViewModel,
                addPadding: true,
                accessControls: aceessControls
            )
            .environmentObject(question)
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
                viewModel: tagsViewModel,
                addPadding: true,
                accessControls: aceessControls
            )
            .environmentObject(question)
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

    @ViewBuilder var questionAndAnswer: some View {
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

    @ViewBuilder var completed: some View {
        if question.completed {
            Text("COMPLETED")
                .foregroundColor(.blue)
                .font(.footnote.bold())
        }
    }

    @ViewBuilder var controls: some View {
        if aceessControls.contains(.trailingControls) {
            let padding: CGFloat = sizeClass == .compact ? 4 : 8
            HStack(spacing: padding) {
                let controlSize: CGFloat = 24
                if aceessControls.contains(.microphone) {
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

                if aceessControls.contains(.favorite) {
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

                if aceessControls.contains(.more) {
                    Menu {
                        if aceessControls.contains(.delete) {
                            Button(role: .destructive) {
                                withAnimation {
                                    searchViewModel.delete(question)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Divider()
                        }

                        if aceessControls.contains(.edit) {
                            Button {
                                searchViewModel.editQuestion = question
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }

                        if aceessControls.contains(.copy) {
                            Button {
                                UIPasteboard.general.string = [question.question, question.answer, question.detailDescription]
                                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                                    .joined(separator: "\n")
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }

                        if aceessControls.contains(.reset) {
                            Button {
                                withAnimation {
                                    searchViewModel.resetToFirstLevel(question)
                                }
                            } label: {
                                Label("Reset to first level", systemImage: "goforward")
                            }
                        }

                        if aceessControls.contains(.completed) {
                            Button {
                                withAnimation {
                                    searchViewModel.complete(question)
                                }
                            } label: {
                                Label("Mark as completed", systemImage: "tray.full")
                            }

                            Divider()
                        }

                        if aceessControls.contains(.move) {
                            Menu("Move") {
                                ForEach(leitnersVM.leitners) { leitner in
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
        }
    }
}

struct NormalQuestionRow_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        let question = Preview.leitner.levels.filter { $0.level == 1 }.first?.allQuestions.first as? Question
        let tagVM = TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)
        let searchVM = SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        var body: some View {
            NormalQuestionRow(question: question!, tagsViewModel: tagVM)
                .environmentObject(searchVM)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        Preview()
    }
}
