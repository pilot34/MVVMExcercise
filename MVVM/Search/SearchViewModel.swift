//
//  SearchViewModel.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/22/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {

    private let disposeBag = DisposeBag()
    private let service: MovieServiceProtocol
    private let innerIsLoadingIndicator: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    // MARK: - input
    let searchTapped = PublishRelay<Void>()
    let searchText = BehaviorRelay<String?>(value: nil)

    // MARK: - output
    var searchButtonIsEnabled: Driver<Bool> {
        // we disable "Search" button when text is shorter than 2 symbols
        return searchText
            .asDriver(onErrorJustReturn: nil)
            .map { SearchViewModel.validateQuery($0).isValid }
    }

    var isLoadingIndicator: Driver<Bool> {
        return innerIsLoadingIndicator.asDriver()
    }

    init(service: MovieServiceProtocol, router: RouterProtocol) {
        self.service = service
        bindSearchTapped(router: router)
    }

    private func bindSearchTapped(router: RouterProtocol) {
        let isValidSearch = searchTapped
            .map { [weak self] in self?.searchText.value }
            .map { SearchViewModel.validateQuery($0) }
            .asDriver(onErrorJustReturn: (isValid: false, text: ""))

        // if text is valid -> show search controller
        isValidSearch.filter { $0.isValid }
            .map { [weak self] value -> String in
                // show loading indicator before network request
                self?.innerIsLoadingIndicator.accept(true)
                return value.text
            }
            .flatMap { [weak self] query -> Driver<(query: String, hasResult: Bool)> in
                guard let self = self else { return .never() }
                return self.performSearch(query: query)
                    .asDriver(onErrorRecover: { [weak self] error in
                        self?.innerIsLoadingIndicator.accept(false)
                        router.showError(text: error.localizedDescription)
                        return .never()
                    })
            }
            .map { [weak self] (query, hasResult) in
                self?.innerIsLoadingIndicator.accept(false)
                if hasResult {
                    router.showMovieList(query: query)
                } else {
                    router.showError(text: "No movie found :(")
                }
            }
            .drive()
            .disposed(by: disposeBag)

        // error is shown when we press "Search" in keyboard
        // while text is not valid
        // because we cannot disable "Search" button in keyboard
        isValidSearch.filter { !$0.isValid }.drive(onNext: { _ in
            router.showError(text: "Minimum search query length is \(SearchViewModel.minimumLengthToSearch) symbols")
        }).disposed(by: disposeBag)
    }

    private func performSearch(query: String) -> Single<(query: String, hasResult: Bool)> {
        return service
            .search(query: query, page: firstPage)
            .map { $0.results.count > 0 }
            .map { (query: query, hasResult: $0)}
    }

    private static func validateQuery(_ query: String?) -> (isValid: Bool, text: String) {
        guard let query = query else {
            return (isValid: false, text: "")
        }

        let trimmed = query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let valid = trimmed.count >= minimumLengthToSearch
        return (isValid: valid, text: trimmed)
    }

    private static let minimumLengthToSearch = 2
}
