//
//  LeitnerView.swift
//  LeitnerBox
//
//  Created by hamed on 5/19/22.
//

import SwiftUI
import CoreData

struct LeitnerView: View {
    
    @ObservedObject
    var vm:LeitnerViewModel = LeitnerViewModel()
    
    @AppStorage("pronounceDetailAnswer")
    private var pronounceDetailAnswer = false
    
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
            .sheet(isPresented: $vm.showBackupFileShareSheet, onDismiss: {
                try? vm.backupFile?.deleteDirectory()
            }, content:{
                if let fileUrl = vm.backupFile?.fileURL{
                    ActivityViewControllerWrapper(activityItems: [fileUrl])
                }else{
                    EmptyView()
                }
            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    Button {
                        vm.exportDB()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        vm.clear()
                        vm.showEditOrAddLeitnerAlert.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                    
                    Menu{
                        Toggle(isOn: $pronounceDetailAnswer) {
                            Label("Prononce \ndetails answer ", systemImage: "mic")
                        }
                        Divider()
                    } label: {
                        Label("More", systemImage: "gear")
                    }
                } 
            }
        }
        .customDialog(isShowing: $vm.showEditOrAddLeitnerAlert, content: {
            editOrAddLeitnerView
        })
    }
    
    var editOrAddLeitnerView:some View{
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
            
            Toggle(isOn: $vm.backToTopLevel) {
                Label("Back to top level", systemImage: "arrow.up.to.line")
            }
            
            Button {
                vm.editOrAddLeitner()
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
                vm.showEditOrAddLeitnerAlert.toggle()
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
