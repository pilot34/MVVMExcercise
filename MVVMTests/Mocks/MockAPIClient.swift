//
//  MockAPIClient.swift
//  MVVMTests
//
//  Created by  Gleb Tarasov on 22/09/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import RxCocoa
import RxSwift
import XCTest
@testable import MVVM

class MockAPIClient: APIClientProtocol {
    private let data: Data
    init(file: String) {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: file, withExtension: "json") else {
            fatalError("no file \(file)")
        }
        data = try! Data(contentsOf: url)
    }

    func requestData(method: RequestMethod,
                     path: String,
                     parameters: [String: CustomStringConvertible]) -> Single<Data> {
        return Single.just(data)
    }

    let backgroundScheduler: SchedulerType = SharingScheduler.make()
}
