//
//  MockStorage.swift
//  MVVMTests
//
//  Created by Gleb Tarasov on 9/24/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
@testable import MVVM

class MockStorage: StorageProtocol {
    var array: [String]?
    func store(array: [String], forKey key: String) {
        self.array = array
    }
    func getArray(forKey key: String) -> [String]? {
        return array
    }
}
