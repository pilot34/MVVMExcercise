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

    // MARK: - input
    let searchTapped = PublishRelay<Void>()
    let searchText = BehaviorRelay<String?>(value: nil)

    // MARK: - output
    let searchButtonIsEnabled: Driver<Bool>

    init(router: RouterProtocol) {

        // we disable "Search" button when text is shorter than 2 symbols
        self.searchButtonIsEnabled = searchText
            .asDriver(onErrorJustReturn: nil)
            .map { SearchViewModel.validateQuery($0).isValid }

        let isValidSearch = searchTapped
            .map { [weak self] in self?.searchText.value }
            .map { SearchViewModel.validateQuery($0) }
            .asDriver(onErrorJustReturn: (isValid: false, text: ""))

        // if text is valid -> show search controller
        isValidSearch.filter { $0.isValid }.drive(onNext: {
            router.showMovieList(query: $0.text)
        }).disposed(by: disposeBag)

        // error is shown when we press "Search" in keyboard
        // while text is not valid
        // because we cannot disable "Search" button in keyboard
        isValidSearch.filter { !$0.isValid }.drive(onNext: { _ in
            router.showError(text: "Minimum search query length is \(SearchViewModel.minimumLengthToSearch) symbols")
        }).disposed(by: disposeBag)
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
