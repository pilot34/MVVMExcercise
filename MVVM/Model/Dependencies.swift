//
//  Dependencies.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 05/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation

class Dependencies {
    let client: APIClient
    let movies: MovieService

    init() {
        client = APIClient(baseURL: baseURL)
        movies = MovieService(client: client)
    }
}
