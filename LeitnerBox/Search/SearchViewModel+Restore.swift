//
//  SearchViewModel+Restore.swift
//  LeitnerBox
//
//  Created by hamed on 9/1/23.
//

import Foundation
import SwiftUI

extension SearchViewModel {
    func saveState() {
        if reviewStatus != .unInitialized {
            let reviewState = RestorableReviewState(leitnerId: leitner.id,
                                                    tagName: selectedTag?.name,
                                                    selectedSort: selectedSort,
                                                    offset: offset,
                                                    lastPlayedQuestion: lastPlayedQuestion?.question)
            reviewState.save()
        }
    }

    func restoreState() {
        if reviewStatus == .unInitialized, let restoreStateValue = RestorableReviewState(restoreWith: leitner.id) {
            withAnimation {
                questions.removeAll()
                offset = 0
                selectedTag = sortedTags.first(where: { $0.name == restoreStateValue.tagName })
                selectedSort = restoreStateValue.selectedSort
                while offset < restoreStateValue.offset {
                    fetchMoreQuestion()
                }
                lastPlayedQuestion = questions.first(where: { $0.question == restoreStateValue.lastPlayedQuestion })
                reviewStatus = .isPaused
                objectWillChange.send()
            }
        }
    }
}
