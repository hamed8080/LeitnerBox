//
// TagView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import SwiftUI

struct TagView: View {
    @StateObject var viewModel: TagViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.tags) { tag in
                    NavigationLink {
                        QuestionsInsideTagView(
                            tag: tag,
                            fetchRequest: FetchRequest(sortDescriptors: [.init(\.question)], predicate: NSPredicate(format: "ANY tag.name == %@", tag.name ?? ""), animation: .easeInOut),
                            tagViewModel: TagViewModel(viewContext: context, leitner: viewModel.leitner)
                        )
                    } label: {
                        TagRowView(tag: tag, viewModel: viewModel).onAppear {
                            if tag == viewModel.tags.last {
                                viewModel.loadMore()
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteItems)
            }
            .animation(.easeInOut, value: viewModel.tags)
            .listStyle(.plain)
        }
        .navigationTitle("Manage Tags for \(viewModel.leitner.name ?? "")")
        .toolbar {
            ToolbarItem {
                Button {
                    viewModel.clear()
                    viewModel.showAddOrEditTagDialog.toggle()
                } label: {
                    Label("Add", systemImage: "plus.square")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.5), Color.accentColor)
                }
            }
        }.customDialog(isShowing: $viewModel.showAddOrEditTagDialog) {
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
                string: $viewModel.tagName,
                textEditorHeight: 48
            )

            ColorPicker("Select Color", selection: $viewModel.colorPickerColor)
                .frame(height: 36)

            Button {
                viewModel.editOrAddTag()
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
                viewModel.showAddOrEditTagDialog.toggle()
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
    struct Preview: View {
        static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        @StateObject var viewModel = TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: Preview.leitner)
        var body: some View {
            TagView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
