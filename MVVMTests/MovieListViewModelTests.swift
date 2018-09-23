//
//  MovieListViewModelTests.swift
//  MVVMTests
//
//  Created by Gleb Tarasov on 9/23/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//


import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import MVVM

class MovieListViewModelTests: XCTestCase {
        func testError() {
            let scheduler = TestScheduler()
            let vm = MovieListViewModel(query: "test", service: MockMovieService.error)

            let errorIsHidden = scheduler.record(vm.errorIsHidden)
            let errorText = scheduler.record(vm.errorText)
            let activityIsAnimating = scheduler.record(vm.activityIsAnimating)
            let tableIsHidden = scheduler.record(vm.tableIsHidden)
            let cells = scheduler.record(vm.cells)
            scheduler.start()

            XCTAssertEqual(errorIsHidden.events.count, 1)
            XCTAssertEqual(errorText.events.count, 1)
            XCTAssertEqual(activityIsAnimating.events.count, 1)
            XCTAssertEqual(tableIsHidden.events.count, 1)
            XCTAssertEqual(cells.events.count, 0)

            XCTAssertFalse(errorIsHidden.events[0].value.element!)
            XCTAssertEqual(errorText.events[0].value.element!, "TestError")
            XCTAssertFalse(activityIsAnimating.events[0].value.element!)
            XCTAssertTrue(tableIsHidden.events[0].value.element!)
        }

        func testSearch() {
            let service = MockMovieService.simple
            let vm = MovieListViewModel(query: "test", service: service)
            let scheduler = TestScheduler()

            let errorIsHidden = scheduler.record(vm.errorIsHidden)
            let errorText = scheduler.record(vm.errorText)
            let activityIsAnimating = scheduler.record(vm.activityIsAnimating)
            let tableIsHidden = scheduler.record(vm.tableIsHidden)
            let cells = scheduler.record(vm.cells)
            scheduler.start()

            XCTAssertEqual(errorIsHidden.events.count, 1)
            XCTAssertEqual(errorText.events.count, 1)
            XCTAssertEqual(activityIsAnimating.events.count, 1)
            XCTAssertEqual(tableIsHidden.events.count, 1)
            XCTAssertEqual(cells.events.count, 1)


            // data loaded
            XCTAssertTrue(errorIsHidden.events[0].value.element!)
            XCTAssertNil(errorText.events[0].value.element!)
            XCTAssertFalse(activityIsAnimating.events[0].value.element!)
            XCTAssertFalse(tableIsHidden.events[0].value.element!)

            // check cells
            let vms = cells.events[0].value.element!
            XCTAssertEqual(vms.count, 3)
            let vm1 = vms[0]
            XCTAssertEqual(vm1.title, "title1")
            XCTAssertEqual(vm1.subtitle, "")
            XCTAssertEqual(service.lastQuery, "test")
        }
}

