//
//  MockSearchService.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 08/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
@testable import MVVM

class MockSearchService: SearchServiceProtocol {

    enum TestError: LocalizedError {
        case error
        var errorDescription: String? {
            return "TestError"
        }
    }

    static var simple: MockSearchService {
        let s = MockSearchService()
        s.result = [
            Place(placeId: "1", displayName: "Test1", lat: "10", lon: "10"),
            Place(placeId: "2", displayName: "Test2", lat: "20", lon: "20"),
            Place(placeId: "3", displayName: "Test3", lat: "30", lon: "30"),
        ]
        return s
    }

    static var error: MockSearchService {
        let s = MockSearchService()
        s.error = TestError.error
        return s
    }

    private var result: [Place]? = nil
    private var error: Error? = nil

    var lastQuery: String? = nil

    func search(query: String) -> Single<[Place]> {
        self.lastQuery = query
        if let result = result {
            return Single.just(result)
        } else if let error = error {
            return Single.error(error)
        } else {
            return Single.just([])
        }
    }
}
