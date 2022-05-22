//
//  LeitnerView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct LeitnerView: View {
    
    @StateObject
    var vm:LeitnerViewModel = LeitnerViewModel()
    
    var body: some View {
        
        NavigationView{
            ZStack{
                List {
                    ForEach(vm.leitners) { item in                        
                      LeitnerRowView(leitner: item, vm: vm)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    vm.delete(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        vm.showAddLeitnerAlert.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        
        .customDialog(isShowing: $vm.showAddLeitnerAlert, content: {
            VStack(spacing:24){
                Text("Leitner name")
                    .foregroundColor(.accentColor)
                    .font(.title2.bold())
                MultilineTextField(
                    "Enter leitner name",
                    text: $vm.leitnerTitle,
                    textColor: UIColor(named: "textColor")!,
                    backgroundColor: UIColor(.primary.opacity(0.1))
                )
                Button {
                    vm.addItem()
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
                
                Button {
                    vm.showAddLeitnerAlert.toggle()
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
                
            }
        })
        .customDialog(isShowing: $vm.showRenameAlert, content: {
            VStack(spacing:24){
                Text("Leitner name")
                    .foregroundColor(.accentColor)
                    .font(.title2.bold())
                MultilineTextField(
                    "Enter leitner name",
                    text: $vm.leitnerTitle,
                    textColor: UIColor(named: "textColor")!,
                    backgroundColor: UIColor(.primary.opacity(0.1))
                )
                Button {
                    vm.saveRename()
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
                
                
                Button {
                    vm.showRenameAlert.toggle()
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
            }
        })
    }
}

struct LeitnerView_Previews: PreviewProvider {
    
    static var leitner:Leitner{
        let req = Leitner.fetchRequest()
        req.fetchLimit = 1
        let leitner = (try! PersistenceController.preview.container.viewContext.fetch(req)).first!
        return leitner
    }
    
    static var previews: some View {
        LeitnerView(vm: LeitnerViewModel(isPreview: true))
    }
}
