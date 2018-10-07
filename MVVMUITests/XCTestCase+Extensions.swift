//
//  XCTestCase+Extensions.swift
//  MVPUITests
//
//  Created by Gleb Tarasov on 10/7/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import XCTest

extension XCTestCase {
    func wait(forElement element: XCUIElement,
              exists: Bool = true,
              timeout: TimeInterval = 20) {
        let predicate = NSPredicate(format: "exists == %@", NSNumber(value: exists))
        let e = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [ e ], timeout: timeout)
        XCTAssert(result == .completed)
    }
}
