//
//  APIClient.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 09/08/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum RequestMethod {
    case get
}

protocol APIClientProtocol {
    var backgroundScheduler: SchedulerType { get }
    func requestData(method: RequestMethod,
                     path: String,
                     parameters: [String: CustomStringConvertible]) -> Single<Data>
}

enum APIError: Error {
    case wrongURL
}

class APIClient: APIClientProtocol {
    func requestData(method: RequestMethod,
                     path: String,
                     parameters: [String: CustomStringConvertible]) -> Single<Data> {
        let url = baseURL.appendingPathComponent(path)
        guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return Single.error(APIError.wrongURL)
        }
        comps.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value.description)
        }
        guard let resultURL = comps.url else {
            return Single.error(APIError.wrongURL)
        }
        let request = URLRequest(url: resultURL)
        return session.rx.data(request: request).asSingle()
    }

    private let session = URLSession.shared
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    let backgroundScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)
}

extension APIClientProtocol {
    func request<T: Decodable>(method: RequestMethod,
                               path: String,
                               parameters: [String: CustomStringConvertible]) -> Single<T> {
        return requestData(method: method,
                           path: path,
                           parameters: parameters)
            .map {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(T.self, from: $0)
                    return result
                } catch let e {
                    debugPrint("Error: \(e)")
                    throw e
                }
            }
            .subscribeOn(backgroundScheduler)
            .observeOn(SharingScheduler.make())
    }
}
