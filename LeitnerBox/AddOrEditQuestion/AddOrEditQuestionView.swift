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
    
    @Environment(\.presentationMode) var presentationMode
    
    var questionState:((QuestionStateChanged)->())? = nil
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    var body: some View {
        GeometryReader{ reader in
            
            HStack(spacing:0){
                Spacer()
                ScrollView{
                    VStack(spacing:36){
                        TextEditorView(placeholder: "Enter your question here...", string: $vm.question, textEditorHeight: 48)
                        CheckBoxView(isActive: $vm.isManual, text: "Manual Answer")
                        if vm.isManual {
                            TextEditorView(placeholder: "Enter your Answer here...", string: $vm.answer, textEditorHeight: 48)
                            TextEditorView(placeholder: "Enter your description here...", string: $vm.descriptionDetail, textEditorHeight: 48)
                        }
                        HStack{
                            CheckBoxView(isActive: $vm.isCompleted, text: "Complete Answer")

                            Menu {
                                ForEach(vm.tags){ tag in
                                    Button {
                                        withAnimation {
                                            vm.addTagToQuestion(tag)
                                        }
                                    } label: {
                                        Label( "\(tag.name ?? "")", systemImage: "tag")
                                    }
                                }
                            } label: {
                                Label("Tag", systemImage: "tag")
                            }
                        }
                        
                        HStack{
                            let tags = vm.addedTags + (vm.editQuestion?.tagsArray ?? [])
                            QuestionTagsView(tags: tags) { tag in
                                vm.removeTagForQuestio(tag)
                            }
                            Spacer()
                        }
                        
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
                        
                        Button {
                            let state = vm.save()
                            questionState?(state)
                            vm.clear()
                            presentationMode.wrappedValue.dismiss()
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
                        Label("clear", systemImage: "trash")
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
        AddOrEditQuestionView(vm: .init(level: LeitnerView_Previews.leitner.level?.allObjects.first as? Level ?? Level()))
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .preferredColorScheme(.dark)
    }
}

