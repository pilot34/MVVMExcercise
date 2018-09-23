//
//  MovieCellViewModel.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/23/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MovieCellViewModel {
    let posterURL: URL?
    let title: String?
    let releaseDate: String?
    let overview: String?

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()

    init(movie: Movie) {
        title = movie.title
        overview = movie.overview

        if let rd = movie.releaseDateTyped {
            releaseDate = MovieCellViewModel.dateFormatter.string(from: rd)
        } else {
            releaseDate = nil
        }

        if let pp = movie.posterPath {
            posterURL = posterURLPrefix.appendingPathComponent(pp)
        } else {
            posterURL = nil
        }
    }
}
