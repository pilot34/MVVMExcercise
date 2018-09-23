//
//  SuggestionServiceTests.swift
//  MVVMTests
//
//  Created by Gleb Tarasov on 9/24/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
@testable import MVVM
import XCTest

class SuggestionServiceTests: XCTestCase {

    func testSuggestionsSimplyWorks() {
        let storage = MockStorage()
        let service = SuggestionService(storage: storage)
        XCTAssertEqual(service.suggestions(forQuery: nil), [])
        service.storeSuggestion("test")
        XCTAssertEqual(service.suggestions(forQuery: nil), ["test"])
        service.storeSuggestion("test2")
        XCTAssertEqual(service.suggestions(forQuery: nil), ["test2", "test"])
    }
    
    func testDuplicatesAreNotStored() {
        let storage = MockStorage()
        let service = SuggestionService(storage: storage)
        XCTAssertEqual(service.suggestions(forQuery: nil), [])
        service.storeSuggestion("test")
        XCTAssertEqual(service.suggestions(forQuery: nil), ["test"])
        service.storeSuggestion("test")
        XCTAssertEqual(service.suggestions(forQuery: nil), ["test"])
    }

    func testSearchByQueryWorks() {
        let storage = MockStorage()
        let service = SuggestionService(storage: storage)
        service.storeSuggestion("test")
        service.storeSuggestion("qtestq")
        service.storeSuggestion("blabla")

        XCTAssertEqual(service.suggestions(forQuery: nil), ["blabla", "qtestq", "test"])
        XCTAssertEqual(service.suggestions(forQuery: "test"), ["qtestq", "test"])
        XCTAssertEqual(service.suggestions(forQuery: "bla"), ["blabla"])
        XCTAssertEqual(service.suggestions(forQuery: "harry"), [])
    }

    func testReturnsOnly10Suggestions() {
        let storage = MockStorage()
        let service = SuggestionService(storage: storage)

        (0..<30).forEach {
            service.storeSuggestion("suggestion\($0)")
        }

        let desired = (20..<30).reversed().map { "suggestion\($0)" }
        XCTAssertEqual(service.suggestions(forQuery: "sug"), desired)
    }

    func testSuggestionsAreLowercased() {
        let storage = MockStorage()
        let service = SuggestionService(storage: storage)
        service.storeSuggestion("Test")
        service.storeSuggestion("TEST")
        service.storeSuggestion("test")

        XCTAssertEqual(service.suggestions(forQuery: nil), ["test"])
    }

    func testThatSuggestionBecomesFirstAfterReAdding() {
        let storage = MockStorage()
        let service = SuggestionService(storage: storage)
        service.storeSuggestion("test1")
        service.storeSuggestion("test2")
        XCTAssertEqual(service.suggestions(forQuery: nil), ["test2", "test1"])

        service.storeSuggestion("test1")
        XCTAssertEqual(service.suggestions(forQuery: nil), ["test1", "test2"])
    }
}
