//
//  SearchViewModelTests.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 07/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import MVVM


class SearchViewModelTests: XCTestCase {
    func testError() {
        let vm = MovieListViewModel(service: MockSearchService.error)
        let scheduler = TestScheduler()

        let search = scheduler.createColdObservable([.next(25, "test" as String?)]).asDriver(onErrorJustReturn: nil)
        vm.bindSearch(input: search.asObservable())
        let errorIsHidden = scheduler.record(vm.errorIsHidden)
        let errorText = scheduler.record(vm.errorText)
        let activityIsAnimating = scheduler.record(vm.activityIsAnimating)
        let tableIsHidden = scheduler.record(vm.tableIsHidden)
        let cells = scheduler.record(vm.cells)
        scheduler.start()

        XCTAssertEqual(errorIsHidden.events.count, 3)
        XCTAssertEqual(errorText.events.count, 3)
        XCTAssertEqual(activityIsAnimating.events.count, 3)
        XCTAssertEqual(tableIsHidden.events.count, 3)
        XCTAssertEqual(cells.events.count, 0)

        // loading
        XCTAssertTrue(errorIsHidden.events[1].value.element!)
        XCTAssertNil(errorText.events[1].value.element!)
        XCTAssertTrue(activityIsAnimating.events[1].value.element!)
        XCTAssertTrue(tableIsHidden.events[1].value.element!)

        // error occured
        XCTAssertFalse(errorIsHidden.events[2].value.element!)
        XCTAssertEqual(errorText.events[2].value.element!, "TestError")
        XCTAssertFalse(activityIsAnimating.events[2].value.element!)
        XCTAssertTrue(tableIsHidden.events[2].value.element!)
    }

    func testSearch() {
        let service = MockSearchService.simple
        let vm = MovieListViewModel(service: service)
        let scheduler = TestScheduler()

        let search = scheduler.createColdObservable([.next(25, "test" as String?)]).asDriver(onErrorJustReturn: nil)
        vm.bindSearch(input: search.asObservable())
        let errorIsHidden = scheduler.record(vm.errorIsHidden)
        let errorText = scheduler.record(vm.errorText)
/Users/gleb/projects/MVVMExcercise/MVVMTests/TestScheduler+Extensions.swift        let activityIsAnimating = scheduler.record(vm.activityIsAnimating)
        let tableIsHidden = scheduler.record(vm.tableIsHidden)
        let cells = scheduler.record(vm.cells)
        scheduler.start()

        XCTAssertEqual(errorIsHidden.events.count, 3)
        XCTAssertEqual(errorText.events.count, 3)
        XCTAssertEqual(activityIsAnimating.events.count, 3)
        XCTAssertEqual(tableIsHidden.events.count, 3)
        XCTAssertEqual(cells.events.count, 1)

        // loading
        XCTAssertTrue(errorIsHidden.events[1].value.element!)
        XCTAssertNil(errorText.events[1].value.element!)
        XCTAssertTrue(activityIsAnimating.events[1].value.element!)
        XCTAssertTrue(tableIsHidden.events[1].value.element!)

        // data loaded
        XCTAssertTrue(errorIsHidden.events[2].value.element!)
        XCTAssertNil(errorText.events[2].value.element!)
        XCTAssertFalse(activityIsAnimating.events[2].value.element!)
        XCTAssertFalse(tableIsHidden.events[2].value.element!)

        // check cells
        let vms = cells.events[0].value.element!
        XCTAssertEqual(vms.count, 3)
        let vm1 = vms[0]
        XCTAssertEqual(vm1.title, "Test1")
        XCTAssertEqual(vm1.subtitle, "10, 10")
        XCTAssertEqual(service.lastQuery, "test")
    }
}
