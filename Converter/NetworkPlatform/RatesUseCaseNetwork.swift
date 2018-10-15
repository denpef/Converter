//
//  RatesUseCaseNetwork.swift
//  NetworkPlatform
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import RxSwift

final class RatesUseCase: RateUseCase {
    private let network: RatesNetwork

    init(network: RatesNetwork) {
        self.network = network
    }

    func rates(baseCurrency: String) -> Observable<[Rate]> {
        return network.fetchRates(baseCurrency: baseCurrency)
    }

}
