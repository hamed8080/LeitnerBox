//
//  AddOrEditQuestionView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct AddOrEditQuestionView: View {
   
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject
    var vm:QuestionViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        GeometryReader{ reader in
        
            HStack{
                Spacer()
                VStack(spacing:36){
                    
                    Text((vm.editQuestion == nil ? "Add question" : "Edit question").uppercased())
                        .font(.title.weight(.bold))
                        .foregroundColor(.accentColor)
                    
                    MultilineTextField(
                        vm.question.isEmpty == true ? "Enter your question here..." : "",
                        text: $vm.question,
                        textColor: UIColor(named: "textColor")!,
                        backgroundColor: UIColor(.primary.opacity(0.1))
                    )
                    .onChange(of: vm.question) { newValue in
                        
                    }
                    
                    CheckBoxView(isActive: $vm.isManual, text: "Manual Answer")
                    
                    if vm.isManual {
                        MultilineTextField(
                            vm.answer.isEmpty == true ? "Enter your Answer here..." : "",
                            text: $vm.answer,
                            textColor: UIColor(named: "textColor")!,
                            backgroundColor: UIColor(.primary.opacity(0.1))
                        )
                        .onChange(of: vm.answer) { newValue in
                            
                        }
                        
                        MultilineTextField(
                            vm.descriptionDetail.isEmpty == true ? "Enter your description here..." : "",
                            text: $vm.descriptionDetail,
                            textColor: UIColor(named: "textColor")!,
                            backgroundColor: UIColor(.primary.opacity(0.1))
                        )
                        .onChange(of: vm.descriptionDetail) { newValue in
                            
                        }
                    }
                    
                    Button {
                        vm.save()
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
                .frame(width: isIpad ? reader.size.width * 40/100 : .infinity)
                Spacer()
            }
            .animation(.easeInOut, value: vm.isManual)
            .padding()
            .toolbar {
                ToolbarItem {
                    Button(action: vm.clear) {
                        Label("clear", systemImage: "trash")
                    }
                }
            }
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AddOrEditQuestionView(vm: .init(level: Level()))
            .preferredColorScheme(.dark)
    }
}

