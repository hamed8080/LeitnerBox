//
// TagViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Combine
import CoreData
import Foundation
import SwiftUI

class TagViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContext
    @Published var tags: [Tag] = []
    @Published var searchedTags: [Tag] = []
    @Published var leitner: Leitner
    @Published var showAddOrEditTagDialog: Bool = false
    @Published var selectedTag: Tag?
    @Published var tagName: String = ""
    @Published var colorPickerColor: Color = .gray
    @Published var searchText: String = ""
    let count = 20
    var offset = 0
    var hasNext: Bool = true
    private(set) var cancellableSet: Set<AnyCancellable> = []

    var filtered: [Tag] {
        if !searchText.isEmpty {
            return searchedTags
        } else {
            return tags
        }
    }

    init(viewContext: NSManagedObjectContext, leitner: Leitner) {
        self.viewContext = viewContext
        self.leitner = leitner
        $searchText.dropFirst().sink { [weak self] newValue in
            self?.searchTags(text: newValue)
        }
        .store(in: &cancellableSet)
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach(viewContext.delete)
            tags.remove(atOffsets: offsets)
        }
    }

    func deleteTagFromQuestion(_ tag: Tag, _ question: Question) {
        withAnimation {
            tag.removeFromQuestion(question)
        }
    }

    func searchTags(text: String) {
        if text.isEmpty {
            searchedTags = []
            return
        }
        let req = Tag.fetchRequest()
        req.fetchLimit = count
        let predicate = NSPredicate(format: "leitner.id == %d AND name contains[c] %@", leitner.id, text)
        req.predicate = predicate
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        searchedTags = (try? viewContext.fetch(req)) ?? []
    }

    func loadMore() {
        if !hasNext { return }
        let predicate = NSPredicate(format: "leitner.id == %d", leitner.id)
        let req = Tag.fetchRequest()
        req.fetchLimit = count
        req.fetchOffset = offset
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        append(contentOf: (try? viewContext.fetch(req)) ?? [])
        offset += count
    }

    func append(contentOf tags: [Tag]) {
        hasNext = tags.count >= count
        self.tags.append(contentsOf: tags)
    }

    func addToTag(_ tag: Tag, _ question: Question) {
        withAnimation {
            if let tag = tags.first(where: { $0.objectID == tag.objectID }) {
                tag.addToQuestion(question)
            }
        }
    }

    func editOrAddTag() {
        if selectedTag != nil {
            editTag()
        } else {
            addTag()
        }
        PersistenceController.saveDB(viewContext: viewContext)
        clearFields()
    }

    func editTag() {
        selectedTag?.name = tagName
        if let cgColor = colorPickerColor.cgColor {
            selectedTag?.color = UIColor(cgColor: cgColor)
        }
        showAddOrEditTagDialog.toggle()
    }

    func addTag() {
        withAnimation {
            let newItem = Tag(context: viewContext)
            newItem.leitner = leitner
            newItem.name = tagName

            if let cgColor = colorPickerColor.cgColor {
                newItem.color = UIColor(cgColor: cgColor)
            }
            tags.append(newItem)
            showAddOrEditTagDialog.toggle()
        }
    }

    func addTagToQuestion(_ tag: Tag, question: Question?) {
        withAnimation {
            guard let question else { return }
            tag.addToQuestion(question)
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func removeTagForQuestion(_ tag: Tag, question: Question?) {
        withAnimation {
            guard let question else { return }
            tag.removeFromQuestion(question)
            PersistenceController.saveDB(viewContext: viewContext)
        }
    }

    func reset() {
        tags = []
        searchedTags = []
        offset = 0
        clearFields()
    }

    func clearFields() {
        colorPickerColor = .gray
        tagName = ""
        selectedTag = nil
    }
}
