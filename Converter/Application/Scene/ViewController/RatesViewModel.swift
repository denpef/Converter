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
    }

    struct Output {
        //let rates: Variable<[RatesItemSection]>
        let rates: Driver<[RatesItemSection]>
        let pollingTumbler: Driver<[Rate]>
        //let selectedRate: Driver<Rate>
        let error: Driver<Error>
        //let baseAmt: Variable<String?>
    }

    let baseAmt = Variable<String?>("1.00")
    
    private let disposeBag = DisposeBag()
    private let useCase: RateUseCase
    private var polling = PublishRelay<Bool>()
//    private var baseAmt = Variable<String?>("1.00")
    
    init(useCase: RateUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {

        let errorTracker = ErrorTracker()
        //let baseAmt = Variable<String?>("1.00")
        
        input.pollingStart
            .flatMapLatest {
                Observable.just(true)
            }.bind(to: polling).disposed(by: disposeBag)

        input.pollingStop
            .flatMapLatest {
                Observable.just(false)
            }.bind(to: polling).disposed(by: disposeBag)

        let sheduler = ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated))

//        let ratesViewModels = polling.asObservable()
//            .flatMapLatest {isPolling -> Observable<String> in
//                guard isPolling else { return .empty() }
//                let realm = try! Realm()
//                let baseObject = realm.objects(Rate.self).filter("isBase = true").first
//                let baseCurrencyId = baseObject?.title ?? ""
//                return Observable<Int>
//                    .interval(3, scheduler: sheduler)
//                    .observeOn(sheduler)
//                    .debug()
//                    .map { _ in baseCurrencyId }
//            }.flatMapLatest { baseId -> Observable<[Rate]> in
//                return self.useCase
//                    .rates(baseCurrency: baseId)
//                    .trackError(errorTracker)
//            }.asDriverOnErrorJustComplete()
        
        let ratesViewModels = Observable.combineLatest(polling, input.selection)
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
                return Observable<Int>
                    .interval(1, scheduler: sheduler)
                    .observeOn(sheduler)
                    //.debug()
                    .map { _ in baseCurrency }
            }.flatMapLatest { baseId -> Observable<[Rate]> in
                return self.useCase
                    .rates(baseCurrency: baseId)
                    //.debug("==Rates response==/n BASE ID: \(baseId)", trimOutput: true)
                    .trackError(errorTracker)
            }.asDriver(onErrorJustReturn: [])

        
        let realm = try! Realm()
        let query = realm.objects(Rate.self)

        //let testAtm = Observable.just("1")
        
        let items = Observable.combineLatest(Observable.collection(from: query), baseAmt.asObservable())
            .flatMapLatest {(arg) -> Observable<[RateCellViewModel]> in
                let (results, amt) = arg
                return Observable.just(results.toArray().map{ RateCellViewModel(rate: $0, baseAmt: amt) }.sorted {  (lth, rth) -> Bool in lth.rate.isBase })
            }.flatMapLatest { viewModels -> Observable<[RatesItemSection]> in
                let firstSection = RatesItemSection(items: viewModels)
                return Observable.just([firstSection])
            }.asDriver(onErrorJustReturn: [])

//        let items = Observable.combineLatest(Observable.collection(from: query), baseAmt.asObservable())
//            .flatMapLatest {(arg) -> Observable<[RateCellViewModel]> in
//                let (results, amt) = arg
//                return Observable.just(results.toArray().map{ RateCellViewModel(rate: $0, baseAmt: amt) })
//            }.flatMapLatest { viewModels -> Variable<[RatesItemSection]> in
//                let firstSection = RatesItemSection(items: viewModels)
//                return Variable([firstSection])
//            }.asDriver
        
//        let realm = try! Realm()
//
//        let objects = realm.objects(Rate.self).sorted(by: Rate.sortDescriptors)
//        let elements = objects.map({rate -> RateCellViewModel in
//            //let baseAmount = Variable.init(String(rate.ratio))
//            return RateCellViewModel(rate: rate, baseAmt: self.baseAmt)
//        }).sorted {  (lth, rth) -> Bool in lth.rate.isBase }
//
//        let items: Variable<[RatesItemSection]> = Variable([RatesItemSection(items: elements)])
        
//        let query = realm.objects(Rate.self)
//
//        let items = Observable.collection(from: query)
//            .flatMapLatest { results -> Observable<[RateItemViewModel]> in
//                return Observable.of(results.toArray().map { (rate) -> RateItemViewModel in
//                    let va = Variable.init(String(rate.value))
//                    return RateItemViewModel(rate: rate, userAmount: va)
//                    }.sorted {  (lth, rth) -> Bool in lth.rate.isBase })
//            }.flatMapLatest { itemViewModels -> Observable<[RatesItemSection]> in
//                let firstSection = RatesItemSection(items: itemViewModels)
//                return Observable.just([firstSection])
//            }.asDriverOnErrorJustComplete()

        let errors = errorTracker.asDriver()

//        let selectedRate = input.selection.map({ rateItemViewModel -> Observable<String> in
//            rateItemViewModel.
//        })
//            .do(onNext: navigator.toPost)
//        let selectedRate = input.selection
//            .withLatestFrom(items) { rateItemViewModel, sections in
//                guard let index = sections[0].items.firstIndex(where: { $0.rate.title == rateItemViewModel.rate.title}),
//                    index != 0
//                    else { return }
//                sections[0].items.remove(at: index)
//                sections[0].items.insert(rateItemViewModel, at: 0)
//                //mainStore.dispatch(action: PresentableAction(viewState: .success(rates)))
//            }

        return Output(
            rates: items,
            pollingTumbler: ratesViewModels,
            //selectedRate: selectedRate,
            error: errors)
            //baseAmt: baseAmt)
    }
}
