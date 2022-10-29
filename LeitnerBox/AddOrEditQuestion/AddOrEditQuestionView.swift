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

    @Environment(\.dismiss) var dissmiss

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    var synonymsVM: SynonymViewModel

    @StateObject
    var tagVM: TagViewModel

    var body: some View {
        GeometryReader { reader in

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
                                string: $vm.descriptionDetail,
                                textEditorHeight: 48
                            )
                        }
                        CheckBoxView(isActive: $vm.isCompleted, text: "Complete Answer")

                        HStack {
                            Button {
                                withAnimation {
                                    vm.isFavorite.toggle()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: vm.isFavorite == true ? "star.fill" : "star")
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
                            QuestionTagsView(question: vm.question, viewModel: tagVM, accessControls: [.showTags, .addTag, .removeTag])
                            QuestionSynonymsView(viewModel: synonymsVM, accessControls: [.showSynonyms, .addSynonym, .removeSynonym])
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
                .frame(width: sizeClass == .regular ? reader.size.width * (60 / 100) : reader.size.width)
                Spacer()
            }
            .frame(width: reader.size.width)
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
                    Text((vm.isInEditMode ? "Edit question" : "Add question").uppercased())
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
        }
        .contentShape(Rectangle())
        .onDisappear {
            if vm.isInEditMode == false {
                /// For when user enter `AddQuestionView` and click `back` button, delete the `Quesiton(context: vm.viewContext)` from context to prevent `save` incorrectly if somewhere in the application save on the  `Context` get called.
                vm.viewContext.rollback()
            }
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    struct Preview: View {
        static let question = LeitnerView_Previews.leitner.allQuestions.first!
        static let context = PersistenceController.preview.container.viewContext
        @StateObject
        var vm = QuestionViewModel(
            viewContext: context,
            level: LeitnerView_Previews.leitner.levels.first!,
            question: question,
            isInEditMode: true
        )

        @StateObject
        var synonymVM = SynonymViewModel(viewContext: context, question: question)

        @StateObject
        var tagVm = TagViewModel(viewContext: context, leitner: question.level!.leitner!)

        var body: some View {
            AddOrEditQuestionView(vm: vm, synonymsVM: synonymVM , tagVM: tagVm)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
