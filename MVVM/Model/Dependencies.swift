//
//  Dependencies.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 05/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation

/// Class stores all needed objects to construct
/// view controllers and view models
class Dependencies {
    let client: APIClientProtocol
    let movies: MovieServiceProtocol
    let suggestions: SuggestionServiceProtocol
    let storage: StorageProtocol

    init() {
        client = APIClient(baseURL: baseURL)
        movies = MovieService(client: client)
        storage = UserDefaultsStorage()
        suggestions = SuggestionService(storage: storage)
    }
}
