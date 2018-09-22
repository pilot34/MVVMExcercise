//
//  MovieService.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift

struct Movie: Codable, Equatable {
    let id: Int
    let title: String
    let overview: String
}

struct SearchResponse: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [Movie]

    static var empty: SearchResponse {
        return SearchResponse(page: 0,
                              totalResults: 0,
                              totalPages: 0,
                              results: [])
    }
}

protocol MovieServiceProtocol {
    func search(query: String) -> Single<SearchResponse>
}

class MovieService: MovieServiceProtocol {
    private let client: APIClientProtocol
    init(client: APIClientProtocol) {
        self.client = client
    }

    func search(query: String) -> Single<SearchResponse> {
        return client.request(method: .get,
                              path: "search/movie",
                              parameters: [
                                "api_key": apiKey,
                                "page": 1,
                                "query": query
            ])
    }
}
