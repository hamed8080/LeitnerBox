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
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AddOrEditQuestionView(vm: .init(level: Level()))
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .preferredColorScheme(.dark)
    }
}
