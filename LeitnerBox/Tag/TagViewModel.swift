//
// TagViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Combine
import CoreData
import Foundation

class TagViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContextProtocol
    @Published var tags: [Tag] = []
    @Published var searchedTags: [Tag] = []
    @Published var leitner: Leitner
    @Published var showAddOrEditTagDialog: Bool = false
    @Published var selectedTag: Tag?
    @Published var tagName: String = ""
    @Published var colorPickerColor: NSObject?
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

    init(viewContext: NSManagedObjectContextProtocol, leitner: Leitner) {
        self.viewContext = viewContext
        self.leitner = leitner
        $searchText.dropFirst().sink { [weak self] newValue in
            self?.searchTags(text: newValue)
        }
        .store(in: &cancellableSet)
    }

    func deleteItems(offsets: IndexSet) {
        offsets.map { tags[$0] }.forEach(viewContext.delete)
        tags.remove(atOffsets: offsets)
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
        do {
            searchedTags = try viewContext.fetch(req)
        } catch {
            print(error)
        }
    }

    func loadMore() {
        if !hasNext { return }
        let predicate = NSPredicate(format: "leitner.id == %d", leitner.id)
        let req = Tag.fetchRequest()
        req.fetchLimit = count
        req.fetchOffset = offset
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        do {
            append(contentOf: try viewContext.fetch(req))
            offset += count
        } catch {
            print(error)
        }
    }

    func append(contentOf tags: [Tag]) {
        hasNext = tags.count >= count
        self.tags.append(contentsOf: tags)
    }

    func saveAddOrEdit() {
        if selectedTag != nil {
            editTag()
        } else {
            addTag()
        }
        save()
        clearFields()
    }

    func editTag() {
        selectedTag?.name = tagName
        selectedTag?.color = colorPickerColor
        showAddOrEditTagDialog.toggle()
    }

    func addTag() {
        let newItem = Tag(context: viewContext as! NSManagedObjectContext)
        newItem.leitner = leitner
        newItem.name = tagName
        newItem.color = colorPickerColor
        tags.append(newItem)
        showAddOrEditTagDialog.toggle()
    }

    func addTagToQuestion(_ tag: Tag, question: Question?) {
        guard let question else { return }
        tag.addToQuestion(question)
        save()
    }

    func removeTagForQuestion(_ tag: Tag, question: Question?) {
        guard let question else { return }
        tag.removeFromQuestion(question)
        save()
    }

    func reset() {
        tags = []
        searchedTags = []
        offset = 0
        clearFields()
    }

    func clearFields() {
        colorPickerColor = nil
        tagName = ""
        selectedTag = nil
    }

    func save() {
        PersistenceController.saveDB(viewContext: viewContext)
    }
}
