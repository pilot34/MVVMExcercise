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

    private let disposeBag = DisposeBag()

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
        let service = MockMovieService.simple()
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
        XCTAssertEqual(vm1.overview, "overview1")
        XCTAssertEqual(vm1.releaseDate, "12/21/01")
        XCTAssertEqual(vm1.posterURL, URL(string: "https://image.tmdb.org/t/p/w185/1.jpg")!)
        XCTAssertEqual(vm1.title, "title1")
        XCTAssertEqual(service.lastQuery, "test")
    }



    func testLoadMoreWorks() {
        let service = MockMovieService.simple(totalPages: 3)
        let vm = MovieListViewModel(query: "test", service: service)
        let scheduler = TestScheduler()

        let loadMore = scheduler.createColdObservable([
            .next(30, ()),
            .next(60, ()),
            .next(90, ()),
            .next(120, ()),
            ]).asSignal(onErrorJustReturn: ())

        loadMore
            .emit(to: vm.loadMoreTriggered)
            .disposed(by: disposeBag)

        let cells = scheduler.record(vm.cells)
        scheduler.start()

        // we send loadMore 4 times, but it loaded only 3 pages, because
        // there is only 3 pages on MockMovieService
        XCTAssertEqual(cells.events.count, 3)
        let vms0 = cells.events[0].value.element!
        XCTAssertEqual(vms0.count, 3)  // 3 rows - first page
        let vms1 = cells.events[1].value.element!
        XCTAssertEqual(vms1.count, 6) // 6 rows - first and second page
       let vms2 = cells.events[2].value.element!
        XCTAssertEqual(vms2.count, 9) // 9 rows - all three pages
    }
}

