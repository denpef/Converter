//
//  TickersViewModel.swift
//  GithubTickersSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class TickersViewModel: ViewModelType {

    struct Input {
        let pollingStart: Observable<Void>
        let pollingStop: Observable<Void>
        let selection: Observable<TickerItemViewModel?>
    }

    struct Output {
        let tickers: Variable<[TickersItemSection]>
        //let tickers: Driver<[TickersItemSection]>
        let pollingTumbler: Driver<[Ticker]>
        //let selectedTicker: Driver<Ticker>
        let error: Driver<Error>
    }

    private var gueueId = "efimov.background"
    private var timerDisposeBag: DisposeBag?
    private let disposeBag = DisposeBag()
    private let useCase: TickerUseCase
    private let navigator: TickersNavigator
    private let sheduler: SchedulerType!
    private let trigger = PublishSubject<Void>()
    private var polling = PublishRelay<Bool>()

    init(useCase: TickerUseCase, navigator: TickersNavigator) {
        self.useCase = useCase
        self.navigator = navigator
        self.sheduler = ConcurrentMainScheduler.instance
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

        let pollingTumbler = Observable.combineLatest(polling, input.selection)
            .flatMapLatest {isPolling, baseTicker -> Observable<String> in
                guard isPolling else { return .empty() }
                let baseTicker = baseTicker?.ticker.title ?? ""
                return Observable<Int>
                    .interval(1, scheduler: sheduler)
                    .observeOn(sheduler)
                    .debug()
                    .map { _ in baseTicker }
            }.flatMapLatest { baseId -> Observable<[Ticker]> in
                return self.useCase
                    .tickers(baseCurrency: baseId)
                    .trackError(errorTracker)
            }.asDriverOnErrorJustComplete()

        let realm = try! Realm()

        let objects = realm.objects(Ticker.self).sorted(by: Ticker.sortDescriptors)
        let elements = objects.map({ticker -> TickerItemViewModel in
            let va = Variable.init(String(ticker.value))
            return TickerItemViewModel(ticker: ticker, userAmount: va)
        }).sorted {  (lth, rth) -> Bool in lth.ticker.isBase }
        
        let items: Variable<[TickersItemSection]> = Variable([TickersItemSection(items: elements)])
        
//        let query = realm.objects(Ticker.self)
//
//        let items = Observable.collection(from: query)
//            .flatMapLatest { results -> Observable<[TickerItemViewModel]> in
//                return Observable.of(results.toArray().map { (ticker) -> TickerItemViewModel in
//                    let va = Variable.init(String(ticker.value))
//                    return TickerItemViewModel(ticker: ticker, userAmount: va)
//                    }.sorted {  (lth, rth) -> Bool in lth.ticker.isBase })
//            }.flatMapLatest { itemViewModels -> Observable<[TickersItemSection]> in
//                let firstSection = TickersItemSection(items: itemViewModels)
//                return Observable.just([firstSection])
//            }.asDriverOnErrorJustComplete()

        let errors = errorTracker.asDriver()

//        let selectedTicker = input.selection.map({ tickerItemViewModel -> Observable<String> in
//            tickerItemViewModel.
//        })
//            .do(onNext: navigator.toPost)
//        let selectedTicker = input.selection
//            .withLatestFrom(items) { tickerItemViewModel, sections in
//                guard let index = sections[0].items.firstIndex(where: { $0.ticker.title == tickerItemViewModel.ticker.title}),
//                    index != 0
//                    else { return }
//                sections[0].items.remove(at: index)
//                sections[0].items.insert(tickerItemViewModel, at: 0)
//                //mainStore.dispatch(action: PresentableAction(viewState: .success(rates)))
//            }

        return Output(
            tickers: items,
            pollingTumbler: pollingTumbler,
            //selectedTicker: selectedTicker,
            error: errors)
    }
}
