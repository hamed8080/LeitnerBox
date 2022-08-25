//
//  AddOrEditQuestionView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct AddOrEditQuestionView: View {
    
    @ObservedObject
    var vm:QuestionViewModel
    
    @Environment(\.dismiss) var dissmiss

    @Environment(\.horizontalSizeClass)
    var sizeClass

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader{ reader in
            
            HStack(spacing:0){
                Spacer()
                ScrollView{
                    VStack(spacing:36){
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

                        HStack{
                            Button {
                                withAnimation {
                                    vm.isFavorite.toggle()
                                }
                            } label: {
                                HStack{
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
                            let leitner = vm.level.leitner!
                            QuestionTagsView(question: vm.question, viewModel: .init(viewContext: vm.viewContext, leitner: leitner))
                            QuestionSynonymsView(viewModel: .init(viewContext: vm.viewContext, question: vm.question))
                        }

                        Button {
                            vm.save()
                            vm.clear()
                            dissmiss()
                        } label: {
                            HStack{
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
                .frame(width: sizeClass == .regular ? reader.size.width * (60/100) : reader.size.width)
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
                    HStack{
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
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
    
    struct Preview:View{
        
        @StateObject
        var vm = QuestionViewModel(
            viewContext: PersistenceController.preview.container.viewContext,
            level: LeitnerView_Previews.leitner.levels.first!,
            question: LeitnerView_Previews.leitner.allQuestions.first!,
            isInEditMode: true
        )
        var body: some View{
            AddOrEditQuestionView(vm: vm)
        }
    }
    
    static var previews: some View {
        NavigationStack{
            Preview()
        }
    }
}

