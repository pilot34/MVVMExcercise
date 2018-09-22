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

class MovieCell: UITableViewCell {
    func display(viewModel: MovieCellViewModel) {
        textLabel?.text = viewModel.title
        detailTextLabel?.text = viewModel.subtitle
    }
}

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
//        title = viewModel.title
//        viewModel.bindSearch(input: searchBar.rx.text.asObservable())
//
//        viewModel.activityIsAnimating
//            .drive(activityIndicator.rx.isAnimating)
//            .disposed(by: disposeBag)
//
//        viewModel.errorIsHidden
//            .drive(errorLabel.rx.isHidden)
//            .disposed(by: disposeBag)
//
//        viewModel.errorText
//            .drive(errorLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        viewModel.tableIsHidden
//            .drive(tableView.rx.isHidden)
//            .disposed(by: disposeBag)
//
//        viewModel.cells.bind(to: tableView.rx
//            .items(cellIdentifier: "MovieCell", cellType: MovieCell.self)) { _, element, cell in
//            cell.display(viewModel: element)
//        }.disposed(by: disposeBag)
    }
}
