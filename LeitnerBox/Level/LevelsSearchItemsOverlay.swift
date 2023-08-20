//
//  LevelsSearchItemsOverlay.swift
//  LeitnerBox
//
//  Created by hamed on 8/20/23.
//

import SwiftUI

struct LevelsSearchItemsOverlay: View {
    let viewModel: LevelsViewModel
    let container: ObjectsContainer
    @State var searchedResultcount = 0

    var body: some View {
        GeometryReader { reader in
            if searchedResultcount >= 1 {
                List {
                    LevelsSearchResults(container: container)
                }
                .listStyle(.plain)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(.keyboard)
                .edgesIgnoringSafeArea(.bottom)
                .frame(width: reader.size.width, height: reader.size.height, alignment: .top)
            }
        }
        .onReceive(viewModel.objectWillChange) { _ in
            if viewModel.searchedQuestions.count != searchedResultcount {
                searchedResultcount = viewModel.searchedQuestions.count
            }
        }
    }
}

struct LevelsSearchResults: View {
    @EnvironmentObject var viewModel: LevelsViewModel
    let container: ObjectsContainer

    var body: some View {
        if viewModel.searchedQuestions.count > 0 || viewModel.searchWord.isEmpty {
            ForEach(viewModel.searchedQuestions) { question in
                NormalQuestionRow(question: question)
                    .environmentObject(container)
            }
        } else {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.gray.opacity(0.8))
                Text("Nothind has found.")
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
    }
}

struct LevelsSearchItemsOverlay_Previews: PreviewProvider {

    struct Preview: View {
        static let context = PersistenceController.shared.viewContext
        static let leitner = PersistenceController.shared.generateAndFillLeitner().first!
        static let container = ObjectsContainer(context: context, leitner: leitner, leitnerVM: .init(viewContext: context))
        @StateObject static var viewModel = LevelsViewModel(viewContext: context, leitner: leitner)

        var body: some View {
            LevelsSearchItemsOverlay(viewModel: Preview.viewModel, container: Preview.container)
                .onAppear {
                    Preview.viewModel.searchWord = "Question"
                }
        }
    }

    static var previews: some View {
        Preview()
    }
}
