//
// TagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 8/28/22.

import CoreData
import SwiftUI

struct TagView: View {
    @ObservedObject
    var vm: TagViewModel

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            List {
                ForEach(vm.tags) { tag in
                    NavigationLink {
                        QuestionsInsideTagView(tag: tag, tagViewModel: TagViewModel(viewContext: vm.viewContext, leitner: vm.leitner))
                    } label: {
                        TagRowView(tag: tag, vm: vm)
                    }
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
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
            }
        }.customDialog(isShowing: $vm.showAddOrEditTagDialog) {
            addOrEditTagDialog
        }
    }

    @ViewBuilder
    var addOrEditTagDialog: some View {
        VStack(spacing: 24) {
            Text("Tag name")
                .foregroundColor(.accentColor)
                .font(.title2.bold())
            TextEditorView(
                placeholder: "Enter tag name",
                shortPlaceholder: "Name",
                string: $vm.tagName,
                textEditorHeight: 48
            )

            ColorPicker("Select Color", selection: $vm.colorPickerColor)
                .frame(height: 36)

            Button {
                vm.editOrAddTag()
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
                vm.showAddOrEditTagDialog.toggle()
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
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var vm: TagViewModel {
        let vm = TagViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner)
        return vm
    }

    static var previews: some View {
        TagView(vm: vm)
            .preferredColorScheme(.light)
    }
}
