//
//  MockRouter.swift
//  MVVMTests
//
//  Created by Gleb Tarasov on 9/23/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
@testable import MVVM

enum LastCall: Equatable {
    case showMovieList(query: String)
    case showError(text: String)
    case none
}

class MockRouter: RouterProtocol {

    func showMovieList(query: String) {
        lastCall = .showMovieList(query: query)
    }

    func showError(text: String) {
        lastCall = .showError(text: text)
    }
    private(set) var lastCall: LastCall = .none
}
