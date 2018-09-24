//
//  SearchResponse.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/24/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation

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
