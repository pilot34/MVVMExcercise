//
//  Constants.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 05/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit

/// Backend URL
let baseURL = URL(string: "https://api.themoviedb.org/3/")!

/// API Key for themoviedb
let apiKey = "2696829a81b1b5827d515ff121700838"

/// First path of URL for poster's posterPath
let posterURLPrefix = URL(string: "https://image.tmdb.org/t/p/w185")!

/// Tint color of the app
let globalTintColor = UIColor(red: 95.0/255,
                              green: 173.0/255,
                              blue: 89.0/255,
                              alpha: 1)

/// Backend uses page 1 as the first page
let firstPage = 1
