//
// AddOrEditQuestionView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct AddOrEditQuestionView: View {
    @StateObject
    var viewModel: QuestionViewModel

    @Environment(\.dismiss)
    var dissmiss

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            ScrollView {
                VStack(spacing: 36) {
                    TextEditorView(
                        placeholder: "Enter your question here...",
                        shortPlaceholder: "Question",
                        string: $viewModel.questionString,
                        textEditorHeight: 48
                    )
                    CheckBoxView(isActive: $viewModel.isManual, text: "Manual Answer")
                    if viewModel.isManual {
                        TextEditorView(
                            placeholder: "Enter your Answer here...",
                            shortPlaceholder: "Answer",
                            string: $viewModel.answer,
                            textEditorHeight: 48
                        )
                        TextEditorView(
                            placeholder: "Enter your description here...",
                            shortPlaceholder: "Description",
                            string: $viewModel.detailDescription,
                            textEditorHeight: 48
                        )
                    }
                    CheckBoxView(isActive: $viewModel.completed, text: "Complete Answer")

                    HStack {
                        Button {
                            withAnimation {
                                viewModel.favorite.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: viewModel.favorite == true ? "star.fill" : "star")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.accentColor)
                                Text(verbatim: "favorite")
                                    .font(.body.weight(.semibold))
                            }
                        }

                        Spacer()
                    }

                    VStack {
                        QuestionTagsView(viewModel: .init(viewContext: context, leitner: viewModel.level.leitner!), accessControls: [.showTags, .addTag, .removeTag])
                            .environmentObject(viewModel.question)
                        QuestionSynonymsView(accessControls: [.showSynonyms, .addSynonym, .removeSynonym])
                            .environmentObject(SynonymViewModel(viewContext: context, question: viewModel.question))
                    }

                    Button {
                        viewModel.save()
                        viewModel.clear()
                        dissmiss()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Save", systemImage: "checkmark.square.fill")
                            Spacer()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.accentColor)

                    Spacer()
                }
                .padding()
            }
            Spacer()
        }
        .animation(.easeInOut, value: viewModel.isManual)
        .toolbar {
            ToolbarItem {
                Button(action: viewModel.clear) {
                    Label("clear", systemImage: "trash.square")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
            }

            ToolbarItem(placement: .principal) {
                Text((viewModel.question.isInserted == false ? "Edit question" : "Add question").uppercased())
                    .font(.body.weight(.bold))
                    .foregroundColor(.accentColor)
            }

            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onDisappear {
            // For when user enter `AddQuestionView` and click `back` button, delete the `Quesiton(context: context)` from context to prevent `save` incorrectly if somewhere in the application save on the  `Context` get called.
            // It's essential to set tag to nil on question, because tag will be deleted completely.
            viewModel.question.tag = nil
            context.rollback()
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    struct Preview: View {
        static let question = LeitnerView_Previews.leitner.allQuestions.first!
        static let context = PersistenceController.shared.viewContext
        @StateObject
        var viewModel = QuestionViewModel(
            viewContext: context,
            leitner: LeitnerView_Previews.leitner,
            question: question
        )

        var body: some View {
            AddOrEditQuestionView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
