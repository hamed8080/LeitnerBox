//
// NormalQuestionRow.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct NormalQuestionRow: View {
    @StateObject var question: Question
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.horizontalSizeClass) var sizeClass
    @State var showTagPicker: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            questionAndAnswer
                .padding([.leading, .trailing])
            HStack {
                levelAndAvailibility
                Spacer()
                completed
                QuestionRowControls(question: question)
            }
            .padding()

            HStack(alignment: .top, spacing: 16) {
                Button {
                    showTagPicker.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("Tags")
                    }
                }
                .buttonStyle(.borderless)

                if let tags = question.tagsArray, tags.count > 0 {
                    QuestionTagList(tags: tags) { tag in
                        objVM.tagVM.removeTagForQuestion(tag, question: question)
                    }
                    .environmentObject(question)
                }
            }
            .padding([.leading, .bottom])
        }
        .sheet(isPresented: $showTagPicker) {
            TagsListPickerView { tag in
                objVM.tagVM.addTagToQuestion(tag, question: question)
            }
        }
    }

    var levelAndAvailibility: some View {
        HStack {
            Text(verbatim: "LEVEL: \(question.level?.level ?? 0)")
                .foregroundColor(.blue)
                .font(.caption2.bold())

            Text(question.remainDays)
                .foregroundColor(.gray)
                .font(.caption2.bold())
        }
    }

    @ViewBuilder var questionAndAnswer: some View {
        Text(question.question ?? "")
            .font(sizeClass == .regular ? .title3.bold() : .body.bold())
            .padding(.top)
        if let answer = question.answer, !answer.isEmpty {
            Text(answer)
                .foregroundColor(.teal)
                .font(sizeClass == .regular ? .body.bold() : .caption.bold())
        }

        if let detailDescription = question.detailDescription, !detailDescription.isEmpty {
            Text(detailDescription)
                .foregroundColor(.gray)
                .font(sizeClass == .regular ? .headline : .caption)
        }
    }

    @ViewBuilder var completed: some View {
        if question.completed {
            Text("COMPLETED")
                .foregroundColor(.blue)
                .font(.caption2.bold())
        }
    }
}

struct QuestionRowControls: View {
    @StateObject var question: Question
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.horizontalSizeClass) var sizeClass
    let controlSize: CGFloat = 18
    var padding: CGFloat { sizeClass == .compact ? 4 : 8 }
    @EnvironmentObject var questionVM: QuestionViewModel

    var body: some View {
        HStack(spacing: padding) {
            Button {
                objVM.searchVM.pronounceOnce(question)
            } label: {
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: controlSize, height: controlSize)
                    .padding(padding)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.borderless)

            Button {
                withAnimation {
                    objVM.searchVM.toggleFavorite(question)
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

            Menu {
                Button(role: .destructive) {
                    withAnimation {
                        objVM.searchVM.delete(question)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Divider()
                NavigationLink {
                    AddOrEditQuestionView()
                        .environmentObject(objVM)
                        .onAppear {
                            objVM.questionVM.question = question
                            objVM.questionVM.setEditQuestionProperties(editQuestion: question)
                        }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    UIPasteboard.general.string = [question.question, question.answer, question.detailDescription]
                        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: "\n")
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button {
                    withAnimation {
                        objVM.searchVM.resetToFirstLevel(question)
                    }
                } label: {
                    Label("Reset to first level", systemImage: "goforward")
                }

                Button {
                    withAnimation {
                        objVM.searchVM.complete(question)
                    }
                } label: {
                    Label("Mark as completed", systemImage: "tray.full")
                }

                Divider()

                Menu("Move") {
                    ForEach(objVM.leitnerVM.leitners) { leitner in
                        Button {
                            withAnimation {
                                self.objVM.searchVM.moveQuestionTo(question, leitner: leitner)
                            }
                        } label: {
                            Label("\(leitner.name ?? "")", systemImage: "folder")
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

struct NormalQuestionRow_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        let question = Question(context: PersistenceController.shared.viewContext)
        let tagVM = TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)
        let searchVM = SearchViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        var body: some View {
            NormalQuestionRow(question: question)
                .environmentObject(tagVM)
                .environmentObject(searchVM)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        Preview()
    }
}
