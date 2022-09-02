//
// LeitnerRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 9/2/22.

import SwiftUI

struct LeitnerRowView: View {
    @ObservedObject
    var leitner: Leitner

    @ObservedObject
    var vm: LeitnerViewModel

    var body: some View {
        HStack {
            Text(leitner.name ?? "")
            Spacer()
            Text(verbatim: "\(leitner.totalQuestionCount)")
                .foregroundColor(.gray)
                .font(.footnote.bold())
        }
        .contextMenu {
            Button {
                vm.selectedLeitner = leitner
                vm.leitnerTitle = vm.selectedLeitner?.name ?? ""
                vm.backToTopLevel = leitner.backToTopLevel
                vm.showEditOrAddLeitnerAlert.toggle()
            } label: {
                Label("Rename and Edit", systemImage: "gear")
            }

            Button {
                withAnimation {
                    vm.selectedLeitner = leitner
                }
            } label: {
                Label("Manage Tags", systemImage: "tag")
            }
        }
    }
}

struct LeitnerRowView_Previews: PreviewProvider {
    static var previews: some View {
        LeitnerRowView(leitner: LeitnerView_Previews.leitner, vm: LeitnerViewModel(viewContext: PersistenceController.preview.container.viewContext))
    }
}
