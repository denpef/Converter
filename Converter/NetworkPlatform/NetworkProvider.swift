//
//  NetworkProvider.swift
//  NetworkPlatform
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import Moya

enum APIManager {
    case getRates(base: String?)
}

final class NetworkProvider {

    public func makeRatesUseCase() -> RatesNetwork {
        let provider = MoyaProvider<APIManager>()
        let network = Network(provider: provider)
        return RatesNetwork(network: network)
    }

}

extension APIManager: TargetType {
    var task: Task {
        switch self {
        case let .getRates(base):
            if let base = base {
                if base != "" {
                    return .requestParameters(parameters: ["base": base], encoding: URLEncoding())
                }
            }
            return .requestPlain
        }
    }

    var baseURL: URL { return URL(string: "https://revolut.duckdns.org/")! }

    var path: String {
        switch self {
        case .getRates:
            return "latest"
        }

    }
    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        switch self {
        case .getRates:
            return Data.stubResponse("Response")
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

extension Data {
    static func stubResponse(_ filename: String) -> Data {
        @objc class TestClass: NSObject { }
        let bundle = Bundle(for: TestClass.self)
        guard let path = bundle.path(forResource: filename, ofType: "json") else {
            return Data()
        }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            #if DEBUG
            fatalError("Failed to load stubbed response: \(error.localizedDescription)")
            #else
            return Data()
            #endif
        }
    }
}
