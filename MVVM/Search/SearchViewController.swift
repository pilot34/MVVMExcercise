//
//  SearchViewController.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/22/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

class SearchViewController: UIViewController {
    var viewModel: SearchViewModel!
    private let disposeBag = DisposeBag()

    /// We have invisible views below and above search text field
    /// And we have 2 constraints with different multipliers
    /// between their heights to control search bar position.
    /// To change position we should enable/disable
    /// constraint with higher priority
    @IBOutlet private var topBottomRatioWithoutKeyboardConstraint: NSLayoutConstraint!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var searchButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewAppeared = false
    }

    /// We need to track if view is visible
    /// To avoid keyboard animation when is not visible
    private var viewAppeared = false

    @IBAction private func resignResponder() {
        textField.resignFirstResponder()
    }

    private func bind() {
        // "Search" button on keyboard does the same
        // as our search UIButton
        textField.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: viewModel.searchTapped)
            .disposed(by: disposeBag)

        textField.rx.text
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        searchButton.rx.tap
            .bind(to: viewModel.searchTapped)
            .disposed(by: disposeBag)

        // disable search button when no text in field
        viewModel.searchButtonIsEnabled
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // show activity indicator after search was tapped
        viewModel.isLoadingIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        // disable button when request is sending
        viewModel.isLoadingIndicator
            .map { !$0 }
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // move field to the top when keyboard appears
        RxKeyboard.instance.isHidden.drive(onNext: { [weak self] hidden in
            self?.animateKeyboardAppearance(hidden: hidden)
        }).disposed(by: disposeBag)
    }

    private func animateKeyboardAppearance(hidden: Bool) {
        guard viewAppeared else {
            return
        }
        topBottomRatioWithoutKeyboardConstraint.isActive = hidden
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
