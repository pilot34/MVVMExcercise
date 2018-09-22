//
//  SearchServiceTests.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 09/08/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import MVVM

class SearchServiceTests: XCTestCase {

    func testParsing() {
        let scheduler = TestScheduler()
        let client = MockAPIClient(file: "places")
        let service = SearchService(client: client)

        let search = scheduler.record(service.search(query: "blabla"))
        scheduler.start()
        XCTAssertEqual(2, search.events.count)
        let places = search.events.first?.value.element
        XCTAssertNotNil(places)
        XCTAssertTrue(places?.count ?? 0 > 0)
        
        let place = (places?.first)!
        XCTAssertEqual(place.displayName,  "Barnes & Noble Cafe, 235, Daniel Webster Highway, South Nashua, Ward 7, Nashua, Hillsborough County, New Hampshire, 03060, United States of America")
        XCTAssertEqual(place.lat, "42.710832")
        XCTAssertEqual(place.lon, "-71.4429025")
    }
}

