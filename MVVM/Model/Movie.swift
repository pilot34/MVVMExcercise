//
//  Movie.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/24/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter
}()

struct Movie: Codable, Equatable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?

    var releaseDateTyped: Date? {
        // we don't parse dates in dateDecodingStrategy of JSONDecoder,
        // because backend returns empty strings sometimes
        // so the whole parsing process is failed because of wrong
        // date format
        guard let releaseDate = releaseDate else {
            return nil
        }
        return dateFormatter.date(from: releaseDate)
    }
}
