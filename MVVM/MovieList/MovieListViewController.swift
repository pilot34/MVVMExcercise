//
//  SearchResultsViewController.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// Screen with the movies list searched by query
class MovieListViewController: UIViewController {

    var viewModel: MovieListViewModel!

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        bind()
    }

    private func bind() {
        title = viewModel.title

        viewModel.activityIsAnimating
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.errorIsHidden
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.errorText
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.tableIsHidden
            .drive(tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.cells.bind(to: tableView.rx
            .items(cellIdentifier: String(describing: MovieCell.self),
                   cellType: MovieCell.self)) { _, element, cell in
                       cell.display(viewModel: element)
                   }
            .disposed(by: disposeBag)

        tableView.rx.nearBottomEdge
            .emit(to: viewModel.loadMoreTriggered)
            .disposed(by: disposeBag)
    }
}
