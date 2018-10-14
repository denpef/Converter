////
////  TimerModel.swift
////  Converter
////
////  Created by Денис Ефимов on 11.10.2018.
////  Copyright © 2018 Denis Efimov. All rights reserved.
////
//
//import RealmSwift
//import RxCocoa
//import RxSwift
//
//class TimerModel {
//    private let poll = PublishRelay<Bool>()
//    private let base = PublishRelay<String?>()
//    private let disposeBag: DisposeBag
//    private let useCase: TickerUseCase
//
//    init(useCase: TickerUseCase, disposeBag: DisposeBag) {
//        self.disposeBag = disposeBag
//        self.useCase = useCase
//        setupTimer()
//    }
//
//    func setBase(_ base: String) {
//        self.base.accept(base)
//    }
//
//    func startPolling() {
//        poll.accept(true)
//    }
//
//    func stopPolling() {
//        poll.accept(false)
//    }
//
//    private func setupTimer() {
//        return Observable.combineLatest(poll, base)
//            .flatMapLatest { isPolling, baseTicker -> Observable<String> in
//                guard isPolling, let baseTicker = baseTicker else { return .empty() }
//                return Observable<Int>
//                    .interval(1, scheduler: ConcurrentMainScheduler.instance)
//                    .map { _ in baseTicker }
//            }.bind { baseTickerTitle in trigger(of: baseTickerTitle) }
//
//    }
//}
