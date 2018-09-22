//
//  TestScheduler+Extensions.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 08/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxTest
import RxSwift
import XCTest

extension TestScheduler {
    func record<O: ObservableConvertibleType>(_ source: O) -> TestableObserver<O.E> {
        let observer = self.createObserver(O.E.self)
        let disposable = source.asObservable().bind(to: observer)
        self.scheduleAt(100000) {
            disposable.dispose()
        }
        return observer
    }

    convenience init() {
        self.init(initialClock: 0)
    }
}

