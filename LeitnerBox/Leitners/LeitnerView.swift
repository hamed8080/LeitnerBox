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
                        settingView(value)
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
    }
    
    @ViewBuilder
    private func settingView(_ value: String) -> some View {
        if value == "Settings" {
            SettingsView()
                .onAppear {
                    viewModel.settingSelected = true
                }
                .onDisappear {
                    viewModel.settingSelected = false
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
            leadingToolbarView
        }
        .refreshable {
            viewModel.load()
        }
        .listStyle(.insetGrouped)
        .tint(.clear)
        .navigationTitle("Leitner Box")
        .onChange(of: viewModel.selectedLeitner) { newValue in
            if let leitner = newValue {
                viewModel.setLeithner(leitner)
            }
        }
    }

    private var leitnersSection: some View {
        Section(String(localized: .init("Leitners"))) {
            ForEach(viewModel.leitners) { leitner in
                NavigationLink(value: leitner) {
                    LeitnerRowView(leitner: leitner)
                }
                .id(leitner.id)
                .listRowBackground(viewModel.selectedLeitner?.id == leitner.id ? Color(.systemFill) : Color(.secondarySystemGroupedBackground))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    deleteActionView(leitner)
                }
            }
        }
    }

    private var settingSection: some View {
        Section(String(localized: .init("Settings"))) {
            NavigationLink(value: "Settings") {
                HStack {
                    Image(systemName: "gear")
                        .foregroundStyle(Color(named: "AccentColor"))
                        
                    Text("Settings")
                    Spacer()
                }
            }
            .listRowBackground(viewModel.settingSelected ? Color(.systemFill) : Color(.secondarySystemGroupedBackground))
        }
    }

    @ViewBuilder
    private func deleteActionView(_ leitner: Leitner) -> some View {
        Button(role: .destructive) {
            viewModel.delete(leitner)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private var leadingToolbarView: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                viewModel.clear()
                viewModel.showEditOrAddLeitnerAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .accessibilityHint("Add Item")
                        .foregroundStyle(Color(named: "AccentColor"))
                    Spacer()
                }
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
