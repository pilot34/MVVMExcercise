//
//  Storage.swift
//  MVVM
//
//  Created by Gleb Tarasov on 9/23/18.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation

protocol StorageProtocol {
    func store(array: [String], forKey key: String)
    func getArray(forKey key: String) -> [String]?
}

class UserDefaultsStorage: StorageProtocol {
    private let defaults = UserDefaults.standard
    func store(array: [String], forKey key: String) {
        defaults.set(array, forKey: key)
    }
    func getArray(forKey key: String) -> [String]? {
        return defaults.object(forKey: key) as? [String]
    }
}
