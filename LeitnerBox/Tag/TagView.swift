//
//  TagView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct TagView: View {
    
    @ObservedObject
    var vm:TagViewModel
    
    var body: some View {
        ZStack{
            
            List {
                ForEach(vm.tags) { item in
                    TagRowView(tag: item, vm: vm)
                }
                .onDelete(perform: vm.deleteItems)
            }
            .animation(.easeInOut, value: vm.tags)
            .listStyle(.plain)
        }
        .navigationTitle("Manage Tags for \(vm.leitner.name ?? "")")
        .toolbar {
            ToolbarItem {
                Button {
                    vm.clear()
                    vm.showAddOrEditTagDialog.toggle()
                } label: {
                    Label("Add", systemImage: "plus.square")
                }
            }
        }.customDialog(isShowing: $vm.showAddOrEditTagDialog) {
            addOrEditTagDialog
        }
    }
    
    
    @ViewBuilder
    var addOrEditTagDialog:some View{
        VStack(spacing:24){
            Text("Tag name")
                .foregroundColor(.accentColor)
                .font(.title2.bold())
            TextEditorView(placeholder: "Enter tag name", string:  $vm.tagName, textEditorHeight: 48)
            
            ColorPicker("Select Color", selection: $vm.colorPickerColor)
            
            Button {
                vm.editOrAddTag()
            } label: {
                HStack{
                    Spacer()
                    Text("SAVE")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.accentColor)
            
            
            Button {
                vm.showAddOrEditTagDialog.toggle()
            } label: {
                HStack{
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .tint(.red)
        }
    }
}

struct TagView_Previews: PreviewProvider {
    
    static var vm:TagViewModel{
        let vm = TagViewModel(leitner: LeitnerView_Previews.leitner, isPreview: true)
        return vm
    }
    
    static var previews: some View {
        TagView(vm: vm)
            .preferredColorScheme(.light)
    }
}
