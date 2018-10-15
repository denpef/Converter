//
//  UseCaseProviderNetwork.swift
//  NetworkPlatform
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation

public final class NetworkUseCaseProvider: UseCaseProvider {

    private let networkProvider: NetworkProvider

    public init() {
        networkProvider = NetworkProvider()
    }

    public func makeRatesUseCase() -> RateUseCase {
        return RatesUseCase(network: networkProvider.makeRatesUseCase())
    }

}
