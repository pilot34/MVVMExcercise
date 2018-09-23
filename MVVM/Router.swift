//
//  Router.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit

protocol RouterProtocol {
    func showMovieList(query: String)
    func showError(text: String)
}

class Router: RouterProtocol {
    private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private let dependencies = Dependencies()

    private var navigationController: UINavigationController?

    func rootViewController() -> UIViewController {
        let vc = mainStoryboard.instantiate(type: SearchViewController.self)
        let viewModel = SearchViewModel(movies: dependencies.movies,
                                        suggestions: dependencies.suggestions,
                                        router: self)
        vc.viewModel = viewModel
        let nav = UINavigationController(rootViewController: vc)
        self.navigationController = nav
        return nav
    }

    func showMovieList(query: String) {
        let vc = mainStoryboard.instantiate(type: MovieListViewController.self)
        let viewModel = MovieListViewModel(query: query, service: dependencies.movies)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }

    func showError(text: String) {
        let vc = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        navigationController?.present(vc, animated: true, completion: nil)
    }
}
