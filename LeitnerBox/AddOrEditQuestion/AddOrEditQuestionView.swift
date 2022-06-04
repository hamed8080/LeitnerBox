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
                            tags
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
    
    @ViewBuilder
    var tags:some View{
        let tags = vm.addedTags + (vm.editQuestion?.tagsArray ?? [])
        if tags.count > 0{
            HStack(spacing:0){
                Image(systemName: "tag")
                    .frame(width: 36, height: 36, alignment: .leading)
                    .foregroundColor(.accentColor)
                    .padding([.trailing], 8)
                
                ScrollView{
                    LazyHGrid(rows: [.init(.flexible(minimum: 48, maximum: 48), spacing: 8, alignment: .leading)]) {
                        ForEach(tags) { tag in
                            Text("\(tag.name ?? "")")
                                .foregroundColor( ((tag.color as? UIColor)?.isLight() ?? false) ? .black : .white)
                                .font(.footnote.weight(.semibold))
                                .padding([.top, .bottom], 4)
                                .padding([.trailing, .leading], 8)
                                .background(
                                    (tag.tagSwiftUIColor ?? .gray)
                                )
                                .onLongPressGesture {
                                    vm.removeTagForQuestio(tag)
                                }
                                .cornerRadius(6)
                                .transition(.asymmetric(insertion: .slide, removal: .scale))
                        }
                    }
                }
            }
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

