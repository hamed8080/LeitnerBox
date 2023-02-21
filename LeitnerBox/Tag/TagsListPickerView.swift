//
// TagsListPickerView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct TagsListPickerView: View {
    @EnvironmentObject var objVM: ObjectsContainer
    var completion: (Tag) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            TopSheetTextEditorView(searchText: $objVM.tagVM.searchText, placeholder: "Search for tags...")
                .listRowSeparator(.hidden)
            ForEach(objVM.tagVM.filtered) { tag in
                Label(tag.name ?? "", systemImage: "tag")
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        completion(tag)
                        dismiss()
                    }
                    .onAppear {
                        if tag == objVM.tagVM.tags.last {
                            objVM.tagVM.loadMore()
                        }
                    }
            }
        }
        .animation(.easeInOut, value: objVM.tagVM.filtered)
        .listStyle(.plain)
        .onAppear {
            objVM.tagVM.loadMore()
        }
        .onDisappear {
            objVM.tagVM.reset()
        }
    }
}

struct AddTagsView_Previews: PreviewProvider {
    static var previews: some View {
        let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
        TagsListPickerView { _ in }
            .environmentObject(TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: leitner))
            .preferredColorScheme(.dark)
    }
}
