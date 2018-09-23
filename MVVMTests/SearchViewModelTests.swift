//
//  SearchViewModelTests.swift
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

class SearchViewModelTests: XCTestCase {
    func testSearchButtonIsEnabledAndDisabledCorrectly() {
        let vm = SearchViewModel(router: MockRouter())
        let scheduler = TestScheduler()

        let search = scheduler.createColdObservable([
            .next(25, "test" as String?),
            .next(50, "q" as String?),
            .next(75, "bla" as String?),
            .next(100, "" as String?),
            .next(150, "test" as String?),
            .next(200, "test2" as String?),
        ]).asDriver(onErrorJustReturn: nil)

        let disposeBag = DisposeBag()
        search.drive(vm.searchText).disposed(by: disposeBag)

        let buttonIsEnabled = scheduler.record(vm.searchButtonIsEnabled)
        scheduler.start()

        XCTAssertEqual(buttonIsEnabled.events, [
            .next(0, false),
            .next(25, true),
            .next(50, false),
            .next(75, true),
            .next(100, false),
            .next(150, true),
            .next(200, true),
            ])
    }

    func testSearchIsShownAfterValidText() {
        let router = MockRouter()
        let vm = SearchViewModel(router: router)

        XCTAssertEqual(router.lastCall, LastCall.none)
        vm.searchText.accept("test")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "test"))

        vm.searchText.accept("G G \n")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "G G"))

        vm.searchText.accept(" GGG")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "GGG"))
    }

    func testErrorIsShownAfterInvalidText() {
        let router = MockRouter()
        let vm = SearchViewModel(router: router)

        XCTAssertEqual(router.lastCall, LastCall.none)
        // empty string is invalid
        vm.searchText.accept("")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall,
                       LastCall.showError(text: "Minimum search query length is 2 symbols"))

        // reset back to non-error state
        vm.searchText.accept("qq")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "qq"))

        // one character is invalid, we accept only 2+ chars
        vm.searchText.accept("1")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall,
                       LastCall.showError(text: "Minimum search query length is 2 symbols"))

        // reset back to non-error state
        vm.searchText.accept("qq")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "qq"))

        vm.searchText.accept("\n\t")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall,
                       LastCall.showError(text: "Minimum search query length is 2 symbols"))

        vm.searchText.accept("qq")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "qq"))

        vm.searchText.accept(nil)
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall,
                       LastCall.showError(text: "Minimum search query length is 2 symbols"))

        vm.searchText.accept("qq")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall, LastCall.showMovieList(query: "qq"))

        vm.searchText.accept("      \n   ")
        vm.searchTapped.accept(())
        XCTAssertEqual(router.lastCall,
                       LastCall.showError(text: "Minimum search query length is 2 symbols"))
    }
}
