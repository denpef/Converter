//
//  Network.swift
//  NetworkPlatform
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import RealmSwift

final class Network {

    var disposeBag: DisposeBag?

    private let scheduler: ConcurrentDispatchQueueScheduler
    private let provider: MoyaProvider<APIManager>

    private var pollingIsEnable: Bool

    init(provider: MoyaProvider<APIManager>) {
        self.scheduler = ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated))
        self.provider = provider
        self.pollingIsEnable = false
    }

    func getItems(baseCurrency: String) -> Observable<[Rate]> {

        let endpoint = APIManager.getRates(base: baseCurrency)

        let decoder = JSONDecoder()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        return provider.rx.request(endpoint)
            .observeOn(scheduler)
            .map(RatesWrapper.self, atKeyPath: nil, using: decoder, failsOnEmptyData: true)
            .flatMap({ wrapper -> Single<[Rate]> in
                print("!!!!REQUEST!!!! \(Date())")
                return Single.just(wrapper.rates)
            }).asObservable()
    }

}
