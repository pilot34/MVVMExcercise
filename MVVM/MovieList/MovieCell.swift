//
//  MovieCell.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/23/18.
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
