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
                .if(.iOS){ view in
                    view.refreshable {
                        vm.load()
                    }
                }
                .listStyle(.plain)
                
                NavigationLink(isActive: $vm.navigateToManageTags) {
                    if let selectedLeitner = vm.selectedLeitner{
                        TagView(vm: TagViewModel(leitner: selectedLeitner))
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
            }
            .sheet(isPresented: $vm.showBackupFileShareSheet, onDismiss: {
                if .iOS == true{
                    try? vm.backupFile?.deleteDirectory()
                }
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
                
                        Menu{
                            ForEach(vm.voices, id:\.self){ voice in
                                let isSelected = vm.selectedVoiceIdentifire == voice.identifier
                                Button {
                                    vm.setSelectedVoice(voice)
                                } label: {
                                    Text("\(isSelected ? "✔︎" : "") \(voice.name) - \(voice.language)")
                                }
                            }
                            Divider()
                            
                        } label: {
                            Label("Pronounce Voice", systemImage: "waveform")
                        }
                        
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
            TextEditorView(placeholder: "Enter leitner name", string:  $vm.leitnerTitle, textEditorHeight: 48)
            
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
            .tint(.accentColor)
            
            
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
            .tint(.red)
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
