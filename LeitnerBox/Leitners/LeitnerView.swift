//
// LeitnerView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import CoreData
import SwiftUI

struct LeitnerView: View {
    @ObservedObject
    var vm: LeitnerViewModel = .init(viewContext: PersistenceController.shared.container.viewContext)

    @AppStorage("pronounceDetailAnswer")
    private var pronounceDetailAnswer = false

    @State
    var navigationVisibility = true

    @State
    var selectedLeitner: Leitner? = nil

    @State
    var isAnimating: Bool = false

    @State private var progress: CGFloat = 0

    var body: some View {
        NavigationSplitView {
            leitnerSidebarList
        } detail: {
            NavigationStack {
                if let leitner = selectedLeitner {
                    LevelsView(
                        vm: LevelsViewModel(
                            viewContext: vm.viewContext,
                            leitner: leitner
                        ),
                        searchViewModel: SearchViewModel(
                            viewContext: vm.viewContext,
                            leitner: leitner
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $vm.showBackupFileShareSheet, onDismiss: {
            if .iOS == true {
                try? vm.backupFile?.deleteDirectory()
            }
        }, content: {
            if let fileUrl = vm.backupFile?.fileURL {
                ActivityViewControllerWrapper(activityItems: [fileUrl])
            } else {
                EmptyView()
            }
        })
        .customDialog(isShowing: $vm.showEditOrAddLeitnerAlert, content: {
            editOrAddLeitnerView
        })
    }

    var toolbarView: some View {
        HStack {
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

            Menu {
                Toggle(isOn: $pronounceDetailAnswer) {
                    Label("Prononce \ndetails answer ", systemImage: "mic")
                }

                Divider()

                Menu {
                    ForEach(vm.voices, id: \.self) { voice in
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

    var leitnerSidebarList: some View {
        List(vm.leitners, selection: $selectedLeitner.animation()) { leitner in
            NavigationLink(value: leitner) {
                LeitnerRowView(leitner: leitner, vm: vm)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            vm.delete(leitner)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbarView
            }
        }
        .refreshable {
            vm.load()
        }
        .listStyle(.plain)
    }

    var editOrAddLeitnerView: some View {
        VStack(spacing: 24) {
            Text("Leitner name")
                .foregroundColor(.accentColor)
                .font(.title2.bold())
            TextEditorView(
                placeholder: "Enter leitner name",
                shortPlaceholder: "Name",
                string: $vm.leitnerTitle,
                textEditorHeight: 48
            )

            Toggle(isOn: $vm.backToTopLevel) {
                Label("Back to top level", systemImage: "arrow.up.to.line")
            }

            Button {
                vm.editOrAddLeitner()
            } label: {
                HStack {
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
                withAnimation {
                    vm.showEditOrAddLeitnerAlert.toggle()
                }

            } label: {
                HStack {
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
            .animation(.easeInOut, value: vm.showEditOrAddLeitnerAlert)
        }
    }

    @ViewBuilder
    var emptyLeitner: some View {
        if vm.leitners.count == 0 {
            ZStack {
                Rectangle()
                    .animatableGradient(from: [.purple, .green], to: [.yellow, .red], progress: progress)
                    .opacity(0.8)
                ZStack {
                    VStack {
                        Image(systemName: "tray")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                            .frame(width: 64, height: 64)
                        Text("Leitner is empty.")
                            .foregroundColor(.gray)
                            .font(.system(.subheadline, design: .rounded))
                    }
                }
                .frame(width: 256, height: 256)
                .background(.ultraThickMaterial)
                .cornerRadius(24)
            }
            .frame(width: 256, height: 256)
            .cornerRadius(24)
            .onAppear {
                withAnimation(.easeOut(duration: 5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                    progress = 1
                }
            }
        }
    }
}

struct LeitnerView_Previews: PreviewProvider {
    static var leitner: Leitner {
        let req = Leitner.fetchRequest()
        req.fetchLimit = 1
        let leitner = (try! PersistenceController.preview.container.viewContext.fetch(req)).first!
        return leitner
    }

    struct Preview: View {
        @StateObject
        var vm = LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext)
        var body: some View {
            LeitnerView(vm: vm)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
