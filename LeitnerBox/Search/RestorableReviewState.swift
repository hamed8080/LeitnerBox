//
//  RestorableReviewState.swift
//  LeitnerBox
//
//  Created by hamed on 9/1/23.
//

import Foundation

struct RestorableReviewState: Codable {
    let leitnerId: Int64
    let tagName: String?
    let selectedSort: SearchSort
    let offset: Int
    let lastPlayedQuestion: String?

    init(leitnerId: Int64, tagName: String? = nil, selectedSort: SearchSort, offset: Int, lastPlayedQuestion: String? = nil) {
        self.tagName = tagName
        self.selectedSort = selectedSort
        self.offset = offset
        self.lastPlayedQuestion = lastPlayedQuestion
        self.leitnerId = leitnerId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.leitnerId = try container.decode(Int64.self, forKey: .leitnerId)
        self.tagName = try container.decodeIfPresent(String.self, forKey: .tagName)
        self.selectedSort = try container.decode(SearchSort.self, forKey: .selectedSort)
        self.offset = try container.decode(Int.self, forKey: .offset)
        self.lastPlayedQuestion = try container.decodeIfPresent(String.self, forKey: .lastPlayedQuestion)
    }

    init?(restoreWith leitnerId: Int64) {
        if let value = RestorableReviewState.restore(leitnerId: leitnerId) {
            self = value
        } else {
            return nil
        }
    }

    enum CodingKeys: CodingKey {
        case leitnerId
        case tagName
        case selectedSort
        case offset
        case lastPlayedQuestion
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.leitnerId, forKey: .leitnerId)
        try container.encodeIfPresent(self.tagName, forKey: .tagName)
        try container.encode(self.selectedSort, forKey: .selectedSort)
        try container.encode(self.offset, forKey: .offset)
        try container.encodeIfPresent(self.lastPlayedQuestion, forKey: .lastPlayedQuestion)
    }

    func save() {
        let data = try? JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: RestorableReviewState.leitnerReviewId(leitnerId))
    }

    static func restore(leitnerId: Int64) -> Self? {
        guard let data = UserDefaults.standard.value(forKey: leitnerReviewId(leitnerId)) as? Data else { return nil }
        let value = try? JSONDecoder().decode(RestorableReviewState.self, from: data)
        return value
    }

    static func clear(_ leitnerId: Int64) {
        UserDefaults.standard.removeObject(forKey: leitnerReviewId(leitnerId))
    }

    static func leitnerReviewId(_ leitnerId: Int64) -> String { "\(leitnerId)-leitnerReviewId" }
}
