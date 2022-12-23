//
// LeitnerView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import AVFoundation
import CoreData
import SwiftUI

struct LeitnerView: View {
    @EnvironmentObject var viewModel: LeitnerViewModel
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @State var selectedLeitnrId: Leitner.ID?

    var body: some View {
        NavigationSplitView {
            if viewModel.leitners.count == 0 {
                EmptyLeitnerAnimation()
            } else {
                SidebarListView(selectedLeitnrId: $selectedLeitnrId)
            }
        } detail: {
            NavigationStack {
                if let leitner = viewModel.leitners.first(where: { $0.id == selectedLeitnrId }) {
                    LevelsView()
                        .environmentObject(SearchViewModel(viewContext: context, leitner: leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice))
                        .environmentObject(LevelsViewModel(viewContext: context, leitner: leitner))
                }
            }
        }
        .animation(.easeInOut, value: selectedLeitnrId)
        .environment(\.avSpeechSynthesisVoice, AVSpeechSynthesisVoice(identifier: viewModel.selectedVoiceIdentifire ?? "") ?? AVSpeechSynthesisVoice(language: "en-GB")!)
        .sheet(isPresented: Binding(get: { viewModel.backupFile != nil }, set: { _ in })) {
            if .iOS == true {
                Task {
                    await viewModel.deleteBackupFile()
                }
            }
        } content: {
            if let fileUrl = viewModel.backupFile?.fileURL {
                ActivityViewControllerWrapper(activityItems: [fileUrl])
            } else {
                EmptyView()
            }
        }
        .customDialog(isShowing: $viewModel.showEditOrAddLeitnerAlert) {
            editOrAddLeitnerView
        }
        .onAppear {
            if selectedLeitnrId == nil {
                selectedLeitnrId = viewModel.leitners.first?.id
            }
        }
    }

    var editOrAddLeitnerView: some View {
        VStack(spacing: 24) {
            Text("Leitner name")
                .foregroundColor(.accentColor)
                .font(.title2.bold())
            TextEditorView(
                placeholder: "Enter leitner name",
                shortPlaceholder: "Name",
                string: $viewModel.leitnerTitle,
                textEditorHeight: 48
            )

            Toggle(isOn: $viewModel.backToTopLevel) {
                Label("Back to top level", systemImage: "arrow.up.to.line")
            }

            Button {
                viewModel.editOrAddLeitner()
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
                    viewModel.showEditOrAddLeitnerAlert.toggle()
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
            .animation(.easeInOut, value: viewModel.showEditOrAddLeitnerAlert)
        }
    }
}

struct SidebarListView: View {
    @AppStorage("pronounceDetailAnswer") private var pronounceDetailAnswer = false

    @Binding var selectedLeitnrId: Leitner.ID?

    @EnvironmentObject var viewModel: LeitnerViewModel

    var body: some View {
        List(viewModel.leitners, selection: $selectedLeitnrId.animation()) { leitner in
            LeitnerRowView(leitner: leitner, viewModel: viewModel)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.delete(leitner)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbarView
            }
        }
        .refreshable {
            viewModel.load()
        }
        .listStyle(.plain)
    }

    var toolbarView: some View {
        HStack {
            Button {
                Task {
                    await viewModel.exportDB()
                }
            } label: {
                if viewModel.isBackuping {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.accentColor)
                } else {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                viewModel.clear()
                viewModel.showEditOrAddLeitnerAlert.toggle()
            } label: {
                Label("Add Item", systemImage: "plus")
            }

            Menu {
                Toggle(isOn: $pronounceDetailAnswer) {
                    Label("Prononce \ndetails answer ", systemImage: "mic")
                }

                Divider()

                Menu {
                    ForEach(viewModel.voices, id: \.self) { voice in
                        let isSelected = viewModel.selectedVoiceIdentifire == voice.identifier
                        Button {
                            viewModel.setSelectedVoice(voice)
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

/// It has animation so it's better to separate it from the main view.
struct EmptyLeitnerAnimation: View {
    @EnvironmentObject var viewModel: LeitnerViewModel

    @State var isAnimating: Bool = false

    @State private var progress: CGFloat = 0

    var body: some View {
        if viewModel.leitners.count == 0 {
            ZStack {
                Rectangle()
                    .animatableGradient(from: [.purple, .green], toColor: [.yellow, .red], progress: progress)
                    .opacity(0.8)
                ZStack {
                    VStack {
                        Image(systemName: "tray")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                            .frame(width: 64, height: 64)
                        Text("Leitner is empty.\nTap to add new Leitner.")
                            .foregroundColor(.gray)
                            .font(.system(.subheadline, design: .rounded))
                            .multilineTextAlignment(.center)
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
            .onTapGesture {
                viewModel.showEditOrAddLeitnerAlert.toggle()
            }
        }
    }
}

struct LeitnerView_Previews: PreviewProvider {
    struct Preview: View {
        var viewModel: LeitnerViewModel {
            _ = try? PersistenceController.shared.generateAndFillLeitner()
            return LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)
        }

        var body: some View {
            LeitnerView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(viewModel)
        }
    }

    struct EmptyLeitnerAnimationViewPreview: View {
        @StateObject var viewModel = LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)

        var body: some View {
            EmptyLeitnerAnimation()
                .environmentObject(viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
        .previewDisplayName("LeitnerView")

//        NavigationStack {
//            EmptyLeitnerAnimationViewPreview()
//        }
//        .previewDisplayName("EmptyLeitnerAnimationViewPreview")

//        NavigationStack{
//            Text("\(LeitnerView_Previews.leitner.name!)")
//        }
    }
}
