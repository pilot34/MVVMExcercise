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

class SearchViewController: UIViewController, UIGestureRecognizerDelegate {
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
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var suggestionsTableView: UITableView!

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
        bindSearchTapped()
        bindSearchText()
        bindLoadingIndicator()
        bindSearchButtonEnabled()
        bindKeyboardAppearance()
        bindSuggestions()
    }

    private func bindSearchTapped() {
        // "Search" button on keyboard does the same
        // as our search UIButton
        textField.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: viewModel.searchTapped)
            .disposed(by: disposeBag)

        searchButton.rx.tap
            .bind(to: viewModel.searchTapped)
            .disposed(by: disposeBag)
    }

    private func bindSearchText() {
        textField.rx.text
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
    }

    private func bindLoadingIndicator() {
        // show activity indicator after search was tapped
        viewModel.isLoadingIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        // disable button when request is sending
        viewModel.isLoadingIndicator
            .map { !$0 }
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func bindKeyboardAppearance() {
        // move field to the top when keyboard appears
        RxKeyboard.instance.isHidden.drive(onNext: { [weak self] hidden in
            self?.animateKeyboardAppearance(hidden: hidden)
        }).disposed(by: disposeBag)

        // we should ensure that all suggestions are visible above keyboard
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] height in
                self?.suggestionsTableView.contentInset.bottom = height
            })
            .disposed(by: disposeBag)
    }

    private func bindSearchButtonEnabled() {
        // disable search button when no text in field
        viewModel.searchButtonIsEnabled
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func bindSuggestions() {
        Driver.combineLatest(
            RxKeyboard.instance.isHidden,
            viewModel.suggestionsToShow)
            .map { keyboardHidden, suggestions in
                return !keyboardHidden && suggestions.count > 0
            }
            .map {
                $0 ? CGFloat(1) : CGFloat(0)
            }
            .drive(suggestionsTableView.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.suggestionsToShow
            .asObservable()
            .bind(to: suggestionsTableView.rx
                .items(
                    cellIdentifier: suggestionCellIdentifier,
                    cellType: UITableViewCell.self)) { _, element, cell in
                        cell.textLabel?.text = element
                    }
            .disposed(by: disposeBag)

        // send tapped suggestion to textField
        suggestionsTableView.rx
            .modelSelected(String.self)
            .bind(to: textField.rx.value)
            .disposed(by: disposeBag)

        suggestionsTableView.rx
            .modelSelected(String.self)
            .bind(to: viewModel.suggestionTapped)
            .disposed(by: disposeBag)
    }

    private let suggestionCellIdentifier = "SuggestionCell"

    private func animateKeyboardAppearance(hidden: Bool) {
        guard viewAppeared else {
            return
        }
        topBottomRatioWithoutKeyboardConstraint.isActive = hidden
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func viewIsInsideCell(view: UIView) -> Bool {
        if view is UITableViewCell {
            return true
        } else if let superview = view.superview {
            return viewIsInsideCell(view: superview)
        } else {
            return false
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // we user tap recognizer to hide keyboard when user taps on empty space
        // but we should cancel touches if they are on suggestionTableView.cell
        if let view = touch.view, viewIsInsideCell(view: view) {
            return false
        }
        return true
    }
}
