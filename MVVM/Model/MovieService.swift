//
//  MovieService.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift

protocol MovieServiceProtocol {
    func search(query: String, page: Int) -> Single<SearchResponse>
}

class MovieService: MovieServiceProtocol {
    private let client: APIClientProtocol
    init(client: APIClientProtocol) {
        self.client = client
    }

    func search(query: String, page: Int) -> Single<SearchResponse> {
        return client.request(method: .get,
                              path: "search/movie",
                              parameters: [
                                "api_key": apiKey,
                                "page": page,
                                "query": query
            ])
    }
}
