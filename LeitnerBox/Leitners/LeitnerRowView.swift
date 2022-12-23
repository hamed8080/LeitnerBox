//
// LeitnerRowView.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import SwiftUI

struct LeitnerRowView: View {
    @StateObject var leitner: Leitner
    @StateObject var viewModel: LeitnerViewModel

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
                viewModel.selectedLeitner = leitner
                viewModel.leitnerTitle = viewModel.selectedLeitner?.name ?? ""
                viewModel.backToTopLevel = leitner.backToTopLevel
                viewModel.showEditOrAddLeitnerAlert.toggle()
            } label: {
                Label("Rename and Edit", systemImage: "gear")
            }

            Button {
                withAnimation {
                    viewModel.selectedLeitner = leitner
                }
            } label: {
                Label("Manage Tags", systemImage: "tag")
            }
        }
    }
}

struct LeitnerRowView_Previews: PreviewProvider {
    static let leitner = try! PersistenceController.shared.generateAndFillLeitner().first!
    static var previews: some View {
        LeitnerRowView(leitner: LeitnerRowView_Previews.leitner, viewModel: LeitnerViewModel(viewContext: PersistenceController.shared.viewContext))
    }
}
