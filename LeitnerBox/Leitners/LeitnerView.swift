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

    var body: some View {
        NavigationSplitView {
            if viewModel.leitners.count == 0 {
                EmptyLeitnerAnimation()
            } else {
                SidebarListView()
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
        .customDialog(isShowing: $viewModel.showEditOrAddLeitnerAlert) {
            EditOrAddLeitnerView()
        }
        .onAppear {
            if viewModel.selectedLeitner == nil {
                viewModel.selectedLeitner = viewModel.leitners.first
            }
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
    @EnvironmentObject var viewModel: LeitnerViewModel

    var body: some View {
        List(selection: $viewModel.selectedLeitner) {
            leitnersSection
            settingSection
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

    private var leitnersSection: some View {
        Section(String(localized: .init("Leitners"))) {
            ForEach(viewModel.leitners) { leitner in
                NavigationLink(value: leitner) {
                    LeitnerRowView(leitner: leitner)
                }
                .id(leitner.id)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    deleteActionView(leitner)
                }
            }
        }
    }

    private var settingSection: some View {
        Section(String(localized: .init("Settings"))) {
            NavigationLink(value: "Settings") {
                Label("Settings", systemImage: "gear")
            }
        }
    }

    @ViewBuilder
    private func deleteActionView(_ leitner: Leitner) -> some View {
        Button(role: .destructive) {
            onDeleteTapped(leitner)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func onDeleteTapped(_ leitner: Leitner) {
        if viewModel.selectedLeitner?.id == leitner.id {
            // Switch navigation view to nil
            viewModel.selectedLeitner = nil
        }
        viewModel.delete(leitner)
    }
}

struct LeitnerView_Previews: PreviewProvider {
    struct Preview: View {
        var viewModel: LeitnerViewModel {
            _ = PersistenceController.shared.generateAndFillLeitner()
            return LeitnerViewModel(viewContext: PersistenceController.shared.viewContext)
        }

        var body: some View {
            LeitnerView()                
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
