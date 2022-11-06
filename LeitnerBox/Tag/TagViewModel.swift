//
// TagViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation
import SwiftUI

class TagViewModel: ObservableObject {
    @Published
    var viewContext: NSManagedObjectContext

    @Published
    var tags: [Tag] = []

    @Published
    var leitner: Leitner

    @Published
    var showAddOrEditTagDialog: Bool = false

    @Published
    var selectedTag: Tag?

    @Published
    var tagName: String = ""

    @Published
    var colorPickerColor: Color = .gray

    @Published
    var searchText: String = ""

    var filtered: [Tag] {
        if searchText.isEmpty {
            return tags
        } else {
            return tags.filter {
                $0.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }

    init(viewContext: NSManagedObjectContext, leitner: Leitner) {
        self.viewContext = viewContext
        self.leitner = leitner
        load()
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

    func load() {
        let predicate = NSPredicate(format: "leitner.id == %d", leitner.id)
        let req = Tag.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        req.predicate = predicate
        tags = (try? viewContext.fetch(req)) ?? []
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
            clear()
        }
    }

    func clear() {
        colorPickerColor = .gray
        tagName = ""
        selectedTag = nil
    }
}
