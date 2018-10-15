//
//  RatesViewModel.swift
//  GithubRatesSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class RatesViewModel: ViewModelType {

    struct Input {
        let pollingStart: Observable<Void>
        let pollingStop: Observable<Void>
        let selection: Observable<RateCellViewModel?>
        let baseAmt: BehaviorRelay<String?>
    }

    struct Output {
        let rates: Driver<[RatesItemSection]>
        let pollingTumbler: Driver<[Rate]>
        let error: Driver<Error>
    }

    private let disposeBag = DisposeBag()
    private let useCase: RateUseCase
    private var polling = PublishRelay<Bool>()

    init(useCase: RateUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {

        let errorTracker = ErrorTracker()
        
        input.pollingStart
            .flatMapLatest {
                Observable.just(true)
            }.bind(to: polling).disposed(by: disposeBag)

        input.pollingStop
            .flatMapLatest {
                Observable.just(false)
            }.bind(to: polling).disposed(by: disposeBag)

        let sheduler = ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated))
        
        // Combine base currency & timer for correct sync request
        let ratesViewModels = Observable
            .combineLatest(polling, input.selection)
            .flatMapLatest {isPolling, baseRate -> Observable<String> in
                guard isPolling else { return .empty() }
                var baseCurrency = ""
                if let baseRate = baseRate {
                    baseCurrency = baseRate.rate.title
                } else {
                    let realm = try! Realm()
                    let baseObject = realm.objects(Rate.self).filter("isBase = true").first
                    if let baseObject = baseObject {
                        baseCurrency = baseObject.title
                    }
                }
                // Timer loop
                return Observable<Int>
                    .interval(1, scheduler: sheduler)
                    .map { _ in baseCurrency }
            }.flatMapLatest { baseId -> Observable<[Rate]> in
                // Request data
                return self.useCase
                    .rates(baseCurrency: baseId)
                    .trackError(errorTracker)
            }.asDriver(onErrorJustReturn: [])

        let realm = try! Realm()
        let query = realm.objects(Rate.self)

        // Combine realm collection & base currency amount to calculate quotes
        let items = Observable.combineLatest(Observable.collection(from: query), input.baseAmt.asObservable())
            .flatMapLatest {(arg) -> Observable<[RateCellViewModel]> in
                let (results, amt) = arg
                return Observable.just(
                    results
                        .toArray()
                        .map{ RateCellViewModel(rate: $0, baseAmt: amt) }
                        .sorted {  (lth, rth) -> Bool in lth.rate.isBase })
            // Create section
            }.flatMapLatest { viewModels -> Observable<[RatesItemSection]> in
                let firstSection = RatesItemSection(items: viewModels)
                return Observable.just([firstSection])
            }.asDriver(onErrorJustReturn: [])

        let errors = errorTracker.asDriver()

        return Output(
            rates: items,
            pollingTumbler: ratesViewModels,
            error: errors)
    }
}
