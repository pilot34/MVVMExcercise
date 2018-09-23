//
//  SearchViewModel.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieListViewModel {

    private struct TableData {
        let rows: [MovieCellViewModel]
        let page: Int
        let hasMore: Bool
    }

    private enum State {
        case loading
        case empty
        case error(String)
        case rows(TableData)

        var errorText: String? {
            switch self {
            case let .error(error):
                return error
            case let .rows(data) where data.rows.isEmpty:
                return "No data found"
            default:
                return nil
            }
        }

        var showActivity: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }

        fileprivate var tableData: TableData? {
            switch self {
            case let .rows(data) where !data.rows.isEmpty:
                return data
            default:
                return nil
            }
        }
    }

    private let service: MovieServiceProtocol
    private let query: String
    private let disposeBag = DisposeBag()

    var title: String {
        return "Search Places"
    }

    // MARK: - Input

    let refreshTriggered: PublishRelay<Void> = PublishRelay()
    let loadMoreTriggered: PublishRelay<Void> = PublishRelay()

    // MARK: - Inner relays

    private let innerData: BehaviorRelay<State> = BehaviorRelay(value: .empty)
    private let innerDidSelectMovie: PublishRelay<Movie> = PublishRelay()

    private var data: Driver<State> {
        return innerData.asDriver()
    }

    // MARK: - Output

    var activityIsAnimating: Driver<Bool> {
        return data.map { $0.showActivity }
    }

    var errorIsHidden: Driver<Bool> {
        return errorText.map { $0 == nil }
    }

    var errorText: Driver<String?> {
        return data.map { $0.errorText }
    }

    var tableIsHidden: Driver<Bool> {
        return data.map { $0.tableData == nil }
    }

    var cells: Observable<[MovieCellViewModel]> {
        return data
            .map { $0.tableData?.rows }
            .asObservable()
            .filterNil()
    }

    init(query: String, service: MovieServiceProtocol) {
        self.query = query
        self.service = service

        bindLoadMore()
        // pages are counted from 1 on backend
        loadPage(pageIndex: 1)
    }

    private func bindLoadMore() {
        loadMoreTriggered.subscribe(onNext: { [weak self] in
            self?.loadMore()
        }).disposed(by: disposeBag)
    }

    private func loadMore() {
        guard canLoadMore() else {
            return
        }

        let nextPage = (innerData.value.tableData?.page ?? 0) + 1
        loadPage(pageIndex: nextPage)
    }

    private func canLoadMore() -> Bool {
        switch innerData.value {
        case let .rows(data):
            return data.hasMore
        default:
            return false
        }
    }

    func loadPage(pageIndex: Int) {
        let innerDidSelectMovie = self.innerDidSelectMovie
        let innerData = self.innerData

        let tableDataBefore = innerData.value.tableData
        if tableDataBefore?.rows.count ?? 0 == 0 {
            // show loading indicator only for the first page
            innerData.accept(.loading)
        }

        let movies: Driver<SearchResponse> = service
            .search(query: query, page: pageIndex)
            .asDriver(onErrorRecover: { error in
                let err = (error as? LocalizedError)?.localizedDescription ?? ""
                innerData.accept(.error(err))
                return .empty()
            })

        movies
            .map { page in
                let arr = page.results.map { movie in
                    return MovieCellViewModel(movie: movie, didSelect: {
                        innerDidSelectMovie.accept(movie)
                    })
                }

                let allArr = (tableDataBefore?.rows ?? []) + arr
                let tableData = TableData(rows: allArr,
                                          page: page.page,
                                          hasMore: page.hasMore)
                innerData.accept(.rows(tableData))
            }
            .drive()
            .disposed(by: disposeBag)
    }
}
