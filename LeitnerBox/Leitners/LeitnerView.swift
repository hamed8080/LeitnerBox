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
    let context: NSManagedObjectContext

    var body: some View {
        NavigationSplitView {
            if viewModel.leitners.count == 0 {
                EmptyLeitnerAnimation()
            } else {
                SidebarListView(selectedLeitner: $viewModel.selectedLeitner)
                    .navigationDestination(for: String.self) { value in
                        if value == "Settings" {
                            SettingsView()
                        }
                    }
            }
        } detail: {
            NavigationStack {
                if viewModel.selectedLeitner != nil {
                    SelectedLeitnerView()
                }
            }
        }
        .animation(.easeInOut, value: viewModel.selectedLeitner)
        .customDialog(isShowing: $viewModel.showEditOrAddLeitnerAlert) {
            editOrAddLeitnerView
        }
        .onAppear {
            if viewModel.selectedLeitner == nil {
                viewModel.selectedLeitner = viewModel.leitners.first
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

struct SelectedLeitnerView: View {
    @EnvironmentObject var viewModel: LeitnerViewModel

    var body: some View {
        if let container = viewModel.selectedObjectContainer {
            LevelsView(container: container)
                .id(viewModel.selectedLeitner?.id)
                .environmentObject(container.levelsVM)
        }
    }
}

struct SidebarListView: View {
    @Binding var selectedLeitner: Leitner?
    @EnvironmentObject var viewModel: LeitnerViewModel

    var body: some View {
        List(selection: $selectedLeitner) {
            Section(String(localized: .init("Leitners"))) {
                ForEach(viewModel.leitners) { leitner in
                    NavigationLink(value: leitner) {
                        LeitnerRowView(leitner: leitner)
                    }
                    .id(leitner.id)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.delete(leitner)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            Section(String(localized: .init("Settings"))) {
                NavigationLink(value: "Settings") {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.clear()
                    viewModel.showEditOrAddLeitnerAlert.toggle()
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .refreshable {
            viewModel.load()
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Leitner Box")
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
            _ = PersistenceController.shared.generateAndFillLeitner()
            return LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)
        }

        var body: some View {
            LeitnerView(context: PersistenceController.shared.viewContext)                
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
    }
}
