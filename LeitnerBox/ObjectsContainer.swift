//
//  ObjectsContainer.swift
//  LeitnerBox
//
//  Created by hamed on 2/22/23.
//

import Combine
import CoreData
import Foundation
import SwiftUI

final class ObjectsContainer: ObservableObject {
    var leitner: Leitner
    @Published var leitnerVM: LeitnerViewModel
    @Published var searchVM: SearchViewModel
    @Published var levelsVM: LevelsViewModel
    @Published var tagVM: TagViewModel
    @Published var synonymVM: SynonymViewModel
    @Published var questionVM: QuestionViewModel
    private(set) var cancellableSet: Set<AnyCancellable> = []

    init(context: NSManagedObjectContext, leitner: Leitner, leitnerVM: LeitnerViewModel) {
        self.leitner = leitner
        self.leitnerVM = leitnerVM
        searchVM = SearchViewModel(viewContext: context, leitner: leitner, voiceSpeech: EnvironmentValues().avSpeechSynthesisVoice)
        levelsVM = LevelsViewModel(viewContext: context, leitner: leitner)
        tagVM = TagViewModel(viewContext: context, leitner: leitner)
        synonymVM = SynonymViewModel(viewContext: context, leitner: leitner)
        questionVM = QuestionViewModel(viewContext: context, leitner: leitner)

        searchVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellableSet)
        self.leitnerVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellableSet)

        levelsVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellableSet)

        tagVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellableSet)

        synonymVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellableSet)

        questionVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellableSet)
    }
}
