//
//  SuggestionService.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/24/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation

protocol SuggestionServiceProtocol {
    func suggestions(forQuery: String?) -> [String]
    func storeSuggestion(_ suggestion: String)
}

class SuggestionService: SuggestionServiceProtocol {

    init(storage: StorageProtocol) {
        self.storage = storage
    }
    private let storage: StorageProtocol

    private var suggestions: [String] {
        get {
            return storage.getArray(forKey: suggestionsKey) ?? []
        }
        set {
            storage.store(array: newValue, forKey: suggestionsKey)
        }
    }
    private let suggestionsKey = "suggestions"

    func suggestions(forQuery query: String?) -> [String] {
        let all = self.suggestions
        guard let query = query?.lowercased(), !query.isEmpty else {
            return all
        }
        let result = all.filter { $0.contains(query) }
        if result.count <= resultLimit {
            return result
        } else {
            return Array(result[0..<resultLimit])
        }
    }

    func storeSuggestion(_ suggestion: String) {
        let lower = suggestion.lowercased()
        var all = suggestions.filter { $0 != lower}
        all.insert(lower, at: 0)
        if all.count > storeLimit {
            all = Array(all[0..<storeLimit])
        }
        suggestions = all
    }
    private let storeLimit = 100
    private let resultLimit = 10
}
