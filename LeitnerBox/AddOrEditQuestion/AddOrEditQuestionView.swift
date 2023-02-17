//
// AddOrEditQuestionView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct AddOrEditQuestionView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.dismiss) var dissmiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @State var showTagPicker: Bool = false
    @State var showSynonymPicker: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            ScrollView {
                VStack(spacing: 36) {
                    VStack(alignment: .leading) {
                        TextEditorView(
                            placeholder: "Enter your question here...",
                            shortPlaceholder: "Question",
                            string: $objVM.questionVM.questionString,
                            textEditorHeight: 48
                        )
                        if objVM.questionVM.batchInserPhrasesMode {
                            Text("When you are in the batch mode the question filed automatically split all th questions by (NewLine/Enter).")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }

                    if !objVM.questionVM.batchInserPhrasesMode {
                        CheckBoxView(isActive: $objVM.questionVM.isManual, text: "Manual Answer")
                        if objVM.questionVM.isManual {
                            TextEditorView(
                                placeholder: "Enter your Answer here...",
                                shortPlaceholder: "Answer",
                                string: $objVM.questionVM.answer,
                                textEditorHeight: 48
                            )
                            TextEditorView(
                                placeholder: "Enter your description here...",
                                shortPlaceholder: "Description",
                                string: $objVM.questionVM.detailDescription,
                                textEditorHeight: 48
                            )
                        }
                    }
                    CheckBoxView(isActive: $objVM.questionVM.completed, text: "Complete Answer")

                    HStack {
                        Button {
                            withAnimation {
                                objVM.questionVM.favorite.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: objVM.questionVM.favorite == true ? "star.fill" : "star")
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

                    VStack(alignment: .leading) {
                        Button {
                            showTagPicker.toggle()
                        } label: {
                            Label("Tags", systemImage: "plus.circle")
                        }
                        .keyboardShortcut("t", modifiers: [.command])
                        .buttonStyle(.borderless)
                        QuestionTagList(tags: objVM.questionVM.tags) { tag in
                            objVM.questionVM.removeTagForQuestion(tag)
                        }

                        Button {
                            showSynonymPicker.toggle()
                        } label: {
                            Label("Synonyms", systemImage: "plus.circle")
                        }
                        .buttonStyle(.borderless)

                        QuestionSynonymList(synonyms: objVM.questionVM.synonyms) { _ in

                        } onLongClick: { synonymQuestion in
                            objVM.questionVM.removeSynonym(synonymQuestion)
                        }
                    }

                    Button {
                        objVM.questionVM.save()
                        objVM.questionVM.reset()
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
        .animation(.easeInOut, value: objVM.questionVM.tags.count)
        .animation(.easeInOut, value: objVM.questionVM.synonyms.count)
        .animation(.easeInOut, value: objVM.questionVM.completed)
        .animation(.easeInOut, value: objVM.questionVM.favorite)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(objVM.questionVM.title)
        .animation(.easeInOut, value: objVM.questionVM.isManual)
        .toolbar {
            ToolbarItem {
                Button(action: objVM.questionVM.reset) {
                    Label("Clear", systemImage: "trash.square")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
            }

            ToolbarItem {
                Button {
                    withAnimation {
                        objVM.questionVM.batchInserPhrasesMode.toggle()
                    }
                } label: {
                    Label("Pharses", systemImage: objVM.questionVM.batchInserPhrasesMode ? "plus.app" : "rectangle.stack.badge.plus")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
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
        .sheet(isPresented: $showSynonymPicker) {
            QuestionSynonymPickerView { question in
                objVM.questionVM.addSynonym(question)
            }
            .environmentObject(objVM)
        }
        .sheet(isPresented: $showTagPicker) {
            TagsListPickerView { tag in
                objVM.questionVM.addTagToQuestion(tag)
            }
            .environmentObject(objVM)
        }
        .onDisappear {
            objVM.questionVM.reset()
            context.rollback()
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        static let question = Question(context: PersistenceController.shared.viewContext)
        @StateObject var viewModel = QuestionViewModel(
            viewContext: PersistenceController.shared.viewContext,
            leitner: Preview.leitner,
            question: question
        )

        var body: some View {
            AddOrEditQuestionView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
