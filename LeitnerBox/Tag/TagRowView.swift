//
// TagRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct TagRowView: View {
    @StateObject
    var tag: Tag

    @StateObject
    var viewModel: TagViewModel

    var body: some View {
        HStack {
            Text("\(tag.name ?? "")")
            Spacer()
            Text(verbatim: "\(tag.questions.count)")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.gray)
            Circle()
                .fill(tag.tagSwiftUIColor ?? .gray)
                .frame(width: 36, height: 36)
        }
        .contextMenu {
            Button {
                viewModel.selectedTag = tag
                viewModel.tagName = tag.name ?? ""
                viewModel.colorPickerColor = tag.tagSwiftUIColor ?? .gray
                viewModel.showAddOrEditTagDialog.toggle()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }
    }
}

struct TagRowView_Previews: PreviewProvider {
    static var previews: some View {
        TagRowView(
            tag: Tag(context: PersistenceController.shared.viewContext),
            viewModel: TagViewModel(viewContext: PersistenceController.shared.viewContext, leitner: LeitnerView_Previews.leitner)
        )
        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
    }
}
