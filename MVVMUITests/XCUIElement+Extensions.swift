//
//  XCUIElement+Extensions.swift
//  MVPUITests
//
//  Created by Gleb Tarasov on 10/7/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import XCTest

extension XCUIElement {
    var stringValue: String! {
        return value as? String
    }
}
