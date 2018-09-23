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
    private let movies: MovieServiceProtocol
    private let suggestions: SuggestionServiceProtocol
    private let router: RouterProtocol

    private let innerIsLoadingIndicator: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    // MARK: - input
    let searchTapped = PublishRelay<Void>()
    let suggestionTapped = PublishRelay<String>()
    let searchText = BehaviorRelay<String?>(value: nil)

    // MARK: - output
    var searchButtonIsEnabled: Driver<Bool> {
        // we disable "Search" button when text is shorter than 2 symbols
        return searchText
            .asDriver()
            .map { SearchViewModel.validateQuery($0).isValid }
    }

    var isLoadingIndicator: Driver<Bool> {
        return innerIsLoadingIndicator.asDriver()
    }

    var suggestionsToShow: Driver<[String]> {
        return searchText
            .asDriver()
            .map { [weak self] in
                return self?.suggestions
                    .suggestions(forQuery: $0)
                    .map { $0.capitalized } ?? []
            }
    }

    init(movies: MovieServiceProtocol,
         suggestions: SuggestionServiceProtocol,
         router: RouterProtocol) {
        self.movies = movies
        self.suggestions = suggestions
        self.router = router
        bindSearchTapped()
        bindSuggestionTapped()
    }

    private func bindSearchTapped() {
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
            .flatMap { [weak self] query in
                // query backend to check if we have results for this query
                return self?.performSearch(query: query) ?? Driver.never()
            }
            .map { [weak self] (query, hasResult) in
                // either show movie list or show error for empty result
                self?.handleSearchResult(query: query, hasResult: hasResult)
            }
            .drive()
            .disposed(by: disposeBag)

        // error is shown when we press "Search" in keyboard
        // while text is not valid
        // because we cannot disable "Search" button in keyboard
        isValidSearch.filter { !$0.isValid }.drive(onNext: { [weak self] _ in
            self?.router.showError(text:
                "Minimum search query length is \(SearchViewModel.minimumLengthToSearch) symbols")
        }).disposed(by: disposeBag)
    }

    private func bindSuggestionTapped() {
        suggestionTapped.subscribe(onNext: { [weak self] suggestion in
            self?.searchText.accept(suggestion)
            self?.searchTapped.accept(())
        }).disposed(by: disposeBag)
    }

    private func performSearch(query: String) -> Driver<(query: String, hasResult: Bool)> {
        return movies
            .search(query: query, page: firstPage)
            .map { $0.results.count > 0 }
            .map { (query: query, hasResult: $0) }
            .asDriver(onErrorRecover: { [weak self] error in
                // handle network error or any other errors
                self?.innerIsLoadingIndicator.accept(false)
                self?.router.showError(text: error.localizedDescription)
                return .never()
            })
    }

    private func handleSearchResult(query: String, hasResult: Bool) {
        innerIsLoadingIndicator.accept(false)
        if hasResult {
            suggestions.storeSuggestion(query)
            router.showMovieList(query: query)
        } else {
            router.showError(text: "No movie found :(")
        }
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
