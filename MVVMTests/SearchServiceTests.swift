//
//  SearchServiceTests.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import MVVM

class SearchServiceTests: XCTestCase {

    func testCorrectJSONIsParsedCorrectly() {
        let scheduler = TestScheduler()
        let client = MockAPIClient(file: "movies")
        let service = MovieService(client: client)

        let search = scheduler.record(service.search(query: "blabla", page: 1))
        scheduler.start()
        XCTAssertEqual(2, search.events.count)
        let response = search.events.first?.value.element
        XCTAssertNotNil(response)
        XCTAssertTrue(response?.results.count ?? 0 > 0)
        
        let movie = (response?.results.first)!
        let desiredMovie = Movie(id: 268,
                                 title: "Batman",
                                 overview: "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker, who has seized control of Gotham's underworld.",
                                 releaseDate: "1989-06-23",
                                 posterPath: "/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg")
        XCTAssertEqual(movie, desiredMovie)
    }
}

