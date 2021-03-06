//
//  TagRowView.swift
//  LeitnerBox
//
//  Created by hamed on 5/21/22.
//

import SwiftUI

struct TagRowView: View {
    
    @ObservedObject
    var tag:Tag
    
    @ObservedObject
    var vm:TagViewModel
    
    var body: some View {
        HStack{
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
        TagRowView(tag: Tag(context: PersistenceController.preview.container.viewContext), vm: TagViewModel(viewContext: PersistenceController.preview.container.viewContext, leitner: LeitnerView_Previews.leitner))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
