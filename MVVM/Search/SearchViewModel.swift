//
//  SearchViewModel.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 09/08/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchCellViewModel {
    let title: String
    let subtitle: String
    let didSelect: () -> Void

    init(place: Place, didSelect: @escaping () -> Void) {
        title = place.displayName
        subtitle = "\(place.lat), \(place.lon)"
        self.didSelect = didSelect
    }
}

class SearchViewModel {

    enum State {
        case loading
        case empty
        case error(String)
        case rows([SearchCellViewModel])

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

        var tableData: [SearchCellViewModel]? {
            switch self {
            case let .rows(arr) where !arr.isEmpty:
                return arr
            default:
                return nil
            }
        }
    }

    private let service: SearchServiceProtocol
    private let disposeBag = DisposeBag()

    var title: String {
        return "Search Places"
    }

    private var data: Driver<State> {
        return innerData.asDriver()
    }
    private let innerData: BehaviorRelay<State> = BehaviorRelay(value: .empty)

    var didSelectPlace: Signal<Place> {
        return innerDidSelectPlace.asSignal()
    }
    private let innerDidSelectPlace: PublishRelay<Place> = PublishRelay()

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

    var cells: Observable<[SearchCellViewModel]> {
        return data
            .map { $0.tableData }
            .asObservable()
            .filterNil()
    }

    init(service: SearchServiceProtocol) {
        self.service = service
    }

    func bindSearch(input: Observable<String?>) {
        let innerDidSelectPlace = self.innerDidSelectPlace
        let innerData = self.innerData

        let places = input
            .asObservable()
            .throttle(0.3, latest: true, scheduler: MainScheduler.instance)
            .filterNil()
            .map {
                innerData.accept(.loading)
                return $0
            }
            .flatMap { [service] text in
                service.search(query: text).asObservable()
            }

        let viewModels: Observable<Void> = places
            .map { arr in
                let arr = arr.map { place in
                    return SearchCellViewModel(place: place, didSelect: {
                        innerDidSelectPlace.accept(place)
                    })
                }
                return arr
            }
            .map {
                innerData.accept(.rows($0))
            }

        viewModels.subscribe(
            onNext: { _ in },
            onError: { error in
                let err = (error as? LocalizedError)?.localizedDescription ?? ""
                innerData.accept(.error(err))
            },
            onCompleted: nil,
            onDisposed: nil
        ).disposed(by: disposeBag)
    }
}
