//
// AddOrEditQuestionView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI

struct AddOrEditQuestionView: View {
    @StateObject
    var vm: QuestionViewModel

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
                        string: $vm.questionString,
                        textEditorHeight: 48
                    )
                    CheckBoxView(isActive: $vm.isManual, text: "Manual Answer")
                    if vm.isManual {
                        TextEditorView(
                            placeholder: "Enter your Answer here...",
                            shortPlaceholder: "Answer",
                            string: $vm.answer,
                            textEditorHeight: 48
                        )
                        TextEditorView(
                            placeholder: "Enter your description here...",
                            shortPlaceholder: "Description",
                            string: $vm.detailDescription,
                            textEditorHeight: 48
                        )
                    }
                    CheckBoxView(isActive: $vm.completed, text: "Complete Answer")

                    HStack {
                        Button {
                            withAnimation {
                                vm.favorite.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: vm.favorite == true ? "star.fill" : "star")
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
                        QuestionTagsView(question: vm.question, viewModel: .init(viewContext: context, leitner: vm.level.leitner!), accessControls: [.showTags, .addTag, .removeTag])
                        QuestionSynonymsView(viewModel: .init(viewContext: context, question: vm.question), accessControls: [.showSynonyms, .addSynonym, .removeSynonym])
                    }

                    Button {
                        vm.save()
                        vm.clear()
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
        .animation(.easeInOut, value: vm.isManual)
        .toolbar {
            ToolbarItem {
                Button(action: vm.clear) {
                    Label("clear", systemImage: "trash.square")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
            }

            ToolbarItem(placement: .principal) {
                Text((vm.question.isInserted == false ? "Edit question" : "Add question").uppercased())
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
            /// For when user enter `AddQuestionView` and click `back` button, delete the `Quesiton(context: context)` from context to prevent `save` incorrectly if somewhere in the application save on the  `Context` get called.
            if vm.question.isInserted {
                context.rollback()
            }
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    struct Preview: View {
        static let question = LeitnerView_Previews.leitner.allQuestions.first!
        static let context = PersistenceController.previewVC
        @StateObject
        var vm = QuestionViewModel(
            viewContext: context,
            leitner: LeitnerView_Previews.leitner,
            question: question
        )
        
        var body: some View {
            AddOrEditQuestionView(vm: vm)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
