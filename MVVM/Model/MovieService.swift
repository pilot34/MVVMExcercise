//
//  MovieService.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter
}()

struct Movie: Codable, Equatable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?

    var releaseDateTyped: Date? {
        // we don't parse dates in dateDecodingStrategy of JSONDecoder,
        // because backend returns empty strings sometimes
        // so the whole parsing process is failed because of wrong
        // date format
        guard let releaseDate = releaseDate else {
            return nil
        }
        return dateFormatter.date(from: releaseDate)
    }
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

    var hasMore: Bool {
        return page < totalPages && results.count > 0
    }
}

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
