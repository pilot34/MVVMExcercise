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
    let searchTapped = PublishRelay<String?>()

    init(router: RouterProtocol) {
        searchTapped.subscribe(onNext: { text in
            if let text = text {
                router.showMovieList(query: text)
            }
        }).disposed(by: disposeBag)
    }

    func textIsValid(_ text: String?) -> Bool {
        guard let text = text else {
            return false
        }
        return text.count >= minimumLengthToSearch
    }
    private let minimumLengthToSearch = 1
}
