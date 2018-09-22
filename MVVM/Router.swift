//
//  Router.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 09/08/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit

class Router {
    private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private let dependencies = Dependencies()

    func rootViewController() -> UIViewController {
        let vc = mainStoryboard.instantiate(type: SearchViewController.self)
        let viewModel = SearchViewModel(service: dependencies.search)
        vc.viewModel = viewModel
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
}
