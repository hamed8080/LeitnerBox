//
// TagRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

struct TagRowView: View {
    @StateObject
    var tag: Tag

    @StateObject
    var vm: TagViewModel

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
                vm.selectedTag = tag
                vm.tagName = tag.name ?? ""
                vm.colorPickerColor = tag.tagSwiftUIColor ?? .gray
                vm.showAddOrEditTagDialog.toggle()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }
    }
}

struct TagRowView_Previews: PreviewProvider {
    static var previews: some View {
        TagRowView(
            tag: Tag(context: PersistenceController.previewVC),
            vm: TagViewModel(viewContext: PersistenceController.previewVC, leitner: LeitnerView_Previews.leitner)
        )
        .environment(\.managedObjectContext, PersistenceController.previewVC)
    }
}
