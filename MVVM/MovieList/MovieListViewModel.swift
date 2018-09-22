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

struct MovieCellViewModel {
    let title: String
    let subtitle: String
    let didSelect: () -> Void

    init(movie: Movie, didSelect: @escaping () -> Void) {
        title = movie.title
        subtitle = ""
        self.didSelect = didSelect
    }
}

class MovieListViewModel {

    enum State {
        case loading
        case empty
        case error(String)
        case rows([MovieCellViewModel])

        var errorText: String? {
            switch self {
            case let .error(error):
                return error
            case let .rows(arr) where arr.isEmpty:
                return "No data"
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

        var tableData: [MovieCellViewModel]? {
            switch self {
            case let .rows(arr) where !arr.isEmpty:
                return arr
            default:
                return nil
            }
        }
    }

    private let service: MovieServiceProtocol
    private let disposeBag = DisposeBag()

    var title: String {
        return "Search Places"
    }

    private var data: Driver<State> {
        return innerData.asDriver()
    }
    private let innerData: BehaviorRelay<State> = BehaviorRelay(value: .empty)

    var didSelectMovie: Signal<Movie> {
        return innerDidSelectMovie.asSignal()
    }
    private let innerDidSelectMovie: PublishRelay<Movie> = PublishRelay()

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
            .map { $0.tableData }
            .asObservable()
            .filterNil()
    }

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    func bindSearch(input: Driver<String?>) {
//        let innerDidSelectMovie = self.innerDidSelectMovie
//        let innerData = self.innerData
//
//        let movies: Driver<SearchResponse> = input
//            .throttle(0.3, latest: true)
//            .map {
//                innerData.accept(.loading)
//                return $0
//            }
//            .flatMap { [service] text in
//                if text.isEmpty {
//                    return .empty()
//                }
//                return service.search(query: text).asDriver(onErrorRecover: { error in
//                    let err = (error as? LocalizedError)?.localizedDescription ?? ""
//                    innerData.accept(.error(err))
//                    return .empty()
//                })
//            }
//
//        let viewModels: Driver<Void> = movies
//            .map { arr in
//                let arr = arr.results.map { movie in
//                    return MovieCellViewModel(movie: movie, didSelect: {
//                        innerDidSelectMovie.accept(movie)
//                    })
//                }
//                return arr
//            }
//            .map {
//                innerData.accept(.rows($0))
//            }
//
//        viewModels.drive().disposed(by: disposeBag)
    }
}
