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
                            string: $vm.question,
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
                            if let question = vm.editQuestion, let leitner = vm.level.leitner{
                                QuestionTagsView(question: question, viewModel: .init(viewContext: vm.viewContext, leitner: leitner))
                            }

                            if let question = vm.editQuestion {
                                QuestionSynonymsView(viewModel: .init(viewContext: vm.viewContext, question: question))
                            }
                        }
                        
                        Button {
                            let _ = vm.save()
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
                    Text((vm.editQuestion == nil ? "Add question" : "Edit question").uppercased())
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
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AddOrEditQuestionView(vm: .init(viewContext: PersistenceController.preview.container.viewContext, level: LeitnerView_Previews.leitner.levels.first!))
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .preferredColorScheme(.dark)
    }
}

