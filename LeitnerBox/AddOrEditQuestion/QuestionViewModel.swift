//
// QuestionViewModel.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import CoreData
import Foundation

final class QuestionViewModel: ObservableObject {
    @Published var viewContext: NSManagedObjectContext
    @Published var level: Level?
    @Published var isManual = true
    @Published var completed = false
    @Published var answer: String = ""
    @Published var detailDescription: String = ""
    @Published var questionString: String = ""
    @Published var favorite: Bool = false
    @Published var batchInserPhrasesMode = false
    @Published var tags: [Tag] = []
    @Published var synonyms: [Question] = []
    @Published var images: [ImageURL] = []
    let leitner: Leitner
    var question: Question?
    var title: String {
        if batchInserPhrasesMode {
            return "Batch Insert Phrases"
        } else if question == nil {
            return "Add New Question"
        } else {
            return "Edit Question"
        }
    }

    init(viewContext: NSManagedObjectContext, leitner: Leitner, question: Question? = nil) {
        self.leitner = leitner
        self.viewContext = viewContext
        level = question == nil ? Leitner.fetchLevelInsideLeitner(context: viewContext, leitnerId: leitner.id, level: 1) : question?.level
        self.question = question
        // Insert
        if let question {
            // Update
            setEditQuestionProperties(editQuestion: question)
        }
    }

    func saveEdit() {
        guard let question else { return }
        question.question = questionString.trimmingCharacters(in: .whitespacesAndNewlines)
        question.answer = answer
        question.leitner = leitner
        question.detailDescription = detailDescription
        question.completed = completed
        setLevelToLatestIfCompeleted(question)
        setSynonyms(question: question)
        setTags(question: question)
        setImages(question)
        if question.favorite == false, favorite {
            question.favoriteDate = Date()
        }
        question.favorite = favorite
    }

    func insert(question: Question) {
        question.question = self.questionString.trimmingCharacters(in: .whitespacesAndNewlines)
        question.answer = answer
        question.leitner = leitner
        question.detailDescription = self.detailDescription
        question.level = level
        question.completed = completed
        setSynonyms(question: question)
        setTags(question: question)
        setLevelToLatestIfCompeleted(question)
        setImages(question)
        question.createTime = Date()
        question.favorite = favorite
        if question.favorite {
            question.favoriteDate = Date()
        }
        question.question = self.questionString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func setLevelToLatestIfCompeleted(_ question: Question) {
        if question.completed {
            if let lastLevel = level?.leitner?.levels.first(where: { $0.level == 13 }) {
                question.level = lastLevel
                question.passTime = Date()
            }
        }
    }

    func batchInsertPhrases() {
        let phrases = splitPhrases()
        phrases.forEach { phrase in
            let newQuestion = Question(context: viewContext)
            insert(question: newQuestion)
            tags.forEach { tag in
                newQuestion.addToTag(tag)
            }

            if synonyms.count > 0 {
                let synonym = Synonym(context: viewContext)
                synonyms.forEach { synonymQuestion in
                    synonymQuestion.addToSynonyms(synonym)
                }
            }
            newQuestion.question = phrase
        }
    }

    func save() {
        if batchInserPhrasesMode {
            batchInsertPhrases()
        } else if question != nil {
            saveEdit()
        } else {
            insert(question: Question(context: viewContext))
        }
        PersistenceController.saveDB(viewContext: viewContext)
    }

    func reset() {
        tags = []
        synonyms = []
        question = nil
        answer = ""
        questionString = ""
        completed = false
        isManual = true
        favorite = false
        detailDescription = ""
        batchInserPhrasesMode = false
    }

    func setEditQuestionProperties(editQuestion: Question) {
        question = editQuestion
        questionString = editQuestion.question ?? ""
        answer = editQuestion.answer ?? ""
        completed = editQuestion.completed
        detailDescription = editQuestion.detailDescription ?? ""
        favorite = editQuestion.favorite
        synonyms = editQuestion.synonymsArray ?? []
        tags = editQuestion.tagsArray ?? []
        images = editQuestion.imagesArray ?? []
    }

    func addTagToQuestion(_ tag: Tag) {
        if tags.contains(tag) { return }
        tags.append(tag)
    }

    func removeTagForQuestion(_ tag: Tag) {
        tags.removeAll(where: { $0.name == tag.name })
        question?.removeFromTag(tag) // remove editng mode tag
    }

    func addSynonym(_ question: Question) {
        if synonyms.contains(question) { return }
        synonyms.append(question)
    }

    func removeSynonym(_ question: Question) {
        // Remove from local array if we are insert mode and we have never saved the object.
        synonyms.removeAll(where: { $0 == question })
        // Remove when we are edit mode
        if let synonym = question.synonyms?.allObjects.first as? Synonym {
            question.removeFromSynonyms(synonym)
        }
    }

    func splitPhrases() -> [String] {
        questionString.split(separator: "\n").map { String($0) }
    }

    func setSynonyms(question: Question) {
        if let synonyms = question.synonyms?.allObjects as? [Synonym], synonyms.count > 0 {
            synonyms.forEach { synonym in
                self.synonyms.forEach { question in
                    synonym.addToQuestion(question)
                }
            }
        } else {
            let synonym = Synonym(context: viewContext)
            question.addToSynonyms(synonym)
            synonyms.forEach { question in
                synonym.addToQuestion(question)
            }
        }
    }

    func setTags(question: Question) {
        tags.forEach { tag in
            question.addToTag(tag)
        }
    }
    
    func addImage(_ link: String) {
        if images.contains(where: {$0.url == link}) { return }
        let imageURL = ImageURL(context: viewContext)
        imageURL.url = link
        images.append(imageURL)
    }
    
    func removeImage(_ imageURL: ImageURL) {
        images.removeAll{$0 == imageURL}
        question?.removeFromImages(imageURL)
    }
    
    func setImages(_ question: Question) {
        images.forEach { image in
            question.addToImages(image)
        }
    }
    
}
