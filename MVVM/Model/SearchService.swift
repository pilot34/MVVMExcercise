//
//  SearchService.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 09/08/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift

struct Place: Codable {
    let placeId: String
    let displayName: String
    let lat: String
    let lon: String
}

protocol SearchServiceProtocol {
    func search(query: String) -> Single<[Place]>
}

class SearchService: SearchServiceProtocol {
    private let client: APIClientProtocol
    init(client: APIClientProtocol) {
        self.client = client
    }

    func search(query: String) -> Single<[Place]> {
        return client.request(method: .get,
                              path: "search",
                              parameters: [
                                "format": "json",
                                "addressdetails": 1,
                                "q": query
            ])
    }
}
