//
// TagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct TagView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            ForEach(objVM.tagVM.tags) { tag in
                NavigationLink {
                    QuestionsInsideTagView(
                        tag: tag,
                        fetchRequest: FetchRequest(sortDescriptors: [.init(\.question)], predicate: NSPredicate(format: "ANY tag.name == %@", tag.name ?? ""), animation: .easeInOut)
                    )
                    .environmentObject(objVM)
                } label: {
                    TagRowView(tag: tag, viewModel: objVM.tagVM).onAppear {
                        if tag == objVM.tagVM.tags.last {
                            objVM.tagVM.loadMore()
                        }
                    }
                }
            }
            .onDelete(perform: objVM.tagVM.deleteItems)
        }
        .listStyle(.plain)
        .navigationTitle("Manage Tags for \(objVM.tagVM.leitner.name ?? "")")
        .onAppear {
            objVM.tagVM.loadMore()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    objVM.tagVM.showAddOrEditTagDialog.toggle()
                } label: {
                    Label("Add", systemImage: "plus.square")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
            }
        }
        .sheet(isPresented: $objVM.tagVM.showAddOrEditTagDialog) {
            addOrEditTagDialog
        }
    }

    @ViewBuilder var addOrEditTagDialog: some View {
        VStack(spacing: 24) {
            Text("Tag name")
                .foregroundColor(.accentColor)
                .font(.title2.bold())
            TextEditorView(
                placeholder: "Enter tag name",
                shortPlaceholder: "Name",
                string: $objVM.tagVM.tagName,
                textEditorHeight: 48
            )

            ColorPicker("Select Color", selection: $objVM.tagVM.colorPickerColor)
                .frame(height: 36)

            Button {
                objVM.tagVM.editOrAddTag()
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
                objVM.tagVM.showAddOrEditTagDialog.toggle()
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
            Spacer()
        }
        .padding()
    }
}

struct TagView_Previews: PreviewProvider {
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        @StateObject var viewModel = TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)
        var body: some View {
            TagView()
                .environmentObject(viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
