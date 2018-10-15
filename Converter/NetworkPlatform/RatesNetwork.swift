//
//  RatesNetwork.swift
//  NetworkPlatform
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import RxSwift

public final class RatesNetwork {

    private let network: Network

    init(network: Network) {
        self.network = network
    }

    public func fetchRates(baseCurrency: String) -> Observable<[Rate]> {
        return network.getItems(baseCurrency: baseCurrency)
    }

}
