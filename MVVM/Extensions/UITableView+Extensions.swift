//
//  UITableView+Extensions.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/23/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UITableView {
    var nearBottomEdgeNow: Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
    private var edgeOffset: CGFloat { return 100 }
}

extension Reactive where Base: UITableView {
    var nearBottomEdge: Signal<Void> {
        return didScroll
            .map { [weak base] in
                return base?.nearBottomEdgeNow == true
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in }
            .asSignal(onErrorJustReturn: ())
    }
}
