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
import Nuke

class MovieCell: UITableViewCell {
    func display(viewModel: MovieCellViewModel) {
        movieLabel.attributedText = movieAttributedString(viewModel: viewModel)
        if let posterURL = viewModel.posterURL {
            let options = ImageLoadingOptions(placeholder: posterPlaceholder)
            Nuke.loadImage(with: posterURL,
                           options: options,
                           into: posterImageView)
        } else {
            posterImageView.image = posterPlaceholder
        }
    }

    private var posterPlaceholder: UIImage? {
        return UIImage(named: "no_poster")
    }

    private func movieAttributedString(viewModel: MovieCellViewModel) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if let title = viewModel.title {
            result.append(titleAttributedString(title: title))
        }
        appendNewLine(to: result)
        if let date = viewModel.releaseDate {
            result.append(dateAttributedString(date: date))
        }
        appendNewLine(to: result)
        if let overview = viewModel.overview {
            result.append(overviewAttributedString(overview: overview))
        }
        return result
    }

    private func appendNewLine(to string: NSMutableAttributedString) {
        if string.length > 0 {
            string.append(NSAttributedString(string: "\n\n", attributes: [
                .font: UIFont.systemFont(ofSize: 5)
                ]))
        }
    }

    private func titleAttributedString(title: String) -> NSAttributedString {
        return NSAttributedString(string: title, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 17)
            ])
    }

    private func dateAttributedString(date: String) -> NSAttributedString {
        return NSAttributedString(string: date, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .light),
            .foregroundColor: UIColor.lightGray
            ])
    }

    private func overviewAttributedString(overview: String) -> NSAttributedString {
        return NSAttributedString(string: overview, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .light)
            ])
    }

    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet var movieLabel: UILabel!
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
            .items(cellIdentifier: "MovieCell", cellType: MovieCell.self)) { _, element, cell in
            cell.display(viewModel: element)
        }.disposed(by: disposeBag)
    }
}
