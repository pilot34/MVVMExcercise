//
//  MockSearchService.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxTest
@testable import MVVM

class MockMovieService: MovieServiceProtocol {

    enum TestError: LocalizedError {
        case error
        var errorDescription: String? {
            return "TestError"
        }
    }

    static var simple: MockMovieService {
        let s = MockMovieService()
        s.result = SearchResponse(
            page: 1,
            totalResults: 3,
            totalPages: 1,
            results: [
                Movie(id: 1, title: "title1", overview: "overview1"),
                Movie(id: 2, title: "title2", overview: "overview2"),
                Movie(id: 3, title: "title3", overview: "overview3"),
                ])
        return s
    }

    static var error: MockMovieService {
        let s = MockMovieService()
        s.error = TestError.error
        return s
    }

    private var result: SearchResponse? = nil
    private var error: Error? = nil

    var lastQuery: String? = nil

    func search(query: String, page: Int) -> Single<SearchResponse> {
        self.lastQuery = query
        if let result = result {
            return Single.just(result)
        } else if let error = error {
            return Single.error(error)
        } else {
            return Single.just(SearchResponse.empty)
        }
    }
}
