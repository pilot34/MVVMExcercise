//
//  MockSuggestionService.swift
//  MVVMTests
//
//  Created by Gleb Tarasov on 9/24/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
@testable import MVVM

class MockSuggestionService: SuggestionServiceProtocol {
    var suggestions: [String] = []
    func suggestions(forQuery: String?) -> [String] {
        return suggestions
    }

    func storeSuggestion(_ suggestion: String) {
        suggestions += [suggestion]
    }
}
