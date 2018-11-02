//
//  ConverterSpec.swift
//  ConverterTests
//
//  Created by Денис Ефимов on 15.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Quick
import Nimble
import RxTest
import RxSwift
import RxCocoa
import RealmSwift
import Moya
@testable import Converter

class RateViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var rateUseCaseMock: RateUseCaseMock!
        var sut: RatesViewModel!
        var disposeBag: DisposeBag?
        var scheduler: TestScheduler!
        beforeSuite {
            let unitTestsConfiguration = Realm.Configuration(inMemoryIdentifier: "UnitTestsConfiguration")
            Realm.Configuration.defaultConfiguration = unitTestsConfiguration
        }
        
        beforeEach {
            
            self.clearRealm()
            
//            let endpointsClosure: MoyaProvider<APIManager>
//                .EndpointClosure = { (target: APIManager) -> Endpoint in
//                    let sampleResponseClosure = { () -> EndpointSampleResponse in
//                        return .networkResponse(200, target.sampleData)
//                    }
//                    let url = URL(target: target).absoluteString
//                    let endpoint = Endpoint(url: url,
//                                            sampleResponseClosure: sampleResponseClosure,
//                                            method: target.method,
//                                            task: target.task,
//                                            httpHeaderFields: target.headers)
//                    return endpoint
//            }
            
//            let ratesProvider = MoyaProvider<APIManager>(
//                endpointClosure: endpointsClosure,
//                stubClosure: MoyaProvider.immediatelyStub)
            
            rateUseCaseMock = RateUseCaseMock()
            scheduler = TestScheduler(initialClock: 0)
//            SharingScheduler.mock(scheduler: scheduler) {
//                sut = RatesViewModel(useCase: rateUseCaseMock)
//            }
            sut = RatesViewModel(useCase: rateUseCaseMock)
            disposeBag = DisposeBag()
            
//            scheduler.scheduleAt(100) {
//
//                let input = self.createInput(pollingStart: Observable.just(()),
//                                             selection: Observable.just(nil))
//                let output = sut.transform(input: input)
//
//                output.rates
//                    .drive()
//                    .disposed(by: disposeBag!)
//
//                output.error
//                    .drive()
//                    .disposed(by: disposeBag!)
//
//                output.pollingTumbler
//                    .drive()
//                    .disposed(by: disposeBag!)
//
//                // act
//                input.pollingStart.do(onNext: { (()) })
//
//            }
        }
        
        afterEach {
//            scheduler.scheduleAt(1000) {
//                self.subscription.dispose()
//            }
            rateUseCaseMock = nil
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        describe("View Model functional") {
            context("network testing") {
                it("should call rates response after start polling") {
                    
                    // arrange
                    expect(rateUseCaseMock.ratesCalled).toNot(equal(true))
                   
                    let modelSelected = PublishSubject<RateCellViewModel?>()
                    let selected = Observable<RateCellViewModel?>.merge(Observable.just(nil), modelSelected.asObservable())
                    
                    let input = self.createInput(//pollingStart: Observable.just(()),
                        selection: selected,
                        scheduler: scheduler)
                    
                    // --
                    //                        let pollingTumbler = PublishSubject<Bool>()
                    //                        let pollingStart = Observable<Bool>.just(true)
                    //                        let ratesViewModels = Observable
                    //                            .combineLatest(pollingTumbler, input.selection)
                    //                            .flatMapLatest {(arg) -> Observable<String> in
                    //                                print("IT WORK!!!!!!!!!")
                    //                                return Observable.empty()
                    //                        }
                    //                        ratesViewModels.asDriverOnErrorJustComplete().drive().disposed(by: disposeBag!)
                    //                        pollingStart.bind(to: pollingTumbler).disposed(by: disposeBag!)
                    // --
                    
                    let output = sut.transform(input: input)
                    
                    
                    scheduler.scheduleAt(1) {
                        print("SHEDULER 100 - 1")
                        
//                        let modelSelected = PublishSubject<RateCellViewModel?>()
//                        let selected = Observable<RateCellViewModel?>.merge(Observable.just(nil), modelSelected.asObservable())
//
//                        let input = self.createInput(//pollingStart: Observable.just(()),
//                                                     selection: selected,
//                                                     scheduler: scheduler)
//
//                        // --
////                        let pollingTumbler = PublishSubject<Bool>()
////                        let pollingStart = Observable<Bool>.just(true)
////                        let ratesViewModels = Observable
////                            .combineLatest(pollingTumbler, input.selection)
////                            .flatMapLatest {(arg) -> Observable<String> in
////                                print("IT WORK!!!!!!!!!")
////                                return Observable.empty()
////                        }
////                        ratesViewModels.asDriverOnErrorJustComplete().drive().disposed(by: disposeBag!)
////                        pollingStart.bind(to: pollingTumbler).disposed(by: disposeBag!)
//                        // --
//
//                        let output = sut.transform(input: input)
//
//                        let pollingStart = Observable<Bool>.just(true)
//
//                        pollingStart.bind(to: output.polling)
//                            .disposed(by: disposeBag!)
                        
                        output.rates
                            .drive()
                            .disposed(by: disposeBag!)
                        
                        output.error
                            .drive()
                            .disposed(by: disposeBag!)
                        
                        output.pollingTumbler
                            .drive()
                            .disposed(by: disposeBag!)
                        
                        Observable.just(true)
                            .bind(to: output.polling)
                            .disposed(by: disposeBag!)
                        
                        print("SHEDULER 100 - 2")
                    }
                    
                    scheduler.scheduleAt(2) {
                        
                        print("SHEDULER 800 - 1")
                        
                        Observable.just(false)
                            .bind(to: output.polling)
                            .disposed(by: disposeBag!)
                        
                        output.polling.dispose()
                        
                        // assert
                        expect(rateUseCaseMock.ratesCalled).to(equal(true), description: "should have call rates fetch")
                        
                        print("SHEDULER 800 - 2")
                    }
                    scheduler.start()

                }
                
//                it("should clean realm and put sample data from file") {
//                    
//                    let input = self.createInput(pollingStart: Observable.just(()),
//                                                 selection: Observable.just(nil))
//                    let output = sut.transform(input: input)
//                    
//                    output.rates
//                        .drive()
//                        .disposed(by: disposeBag!)
//                    
//                    output.error
//                        .drive()
//                        .disposed(by: disposeBag!)
//                    
//                    output.pollingTumbler
//                        .drive()
//                        .disposed(by: disposeBag!)
//                    
//                    _ = input.pollingStart.do()
//                    
//                    // Realm setup and mock JSON data to database
//                    let realm = try! Realm()
//                    try! realm.write {
//                        let all = realm.objects(Rate.self)
//                        realm.delete(all)
//                    }
//                    
//                    let decoder = JSONDecoder()
//                    let dateFormatter = DateFormatter()
//                    
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
//                    
//                    _ = try! decoder.decode(RatesWrapper.self, from: APIManager.getRates(base: "EUR").sampleData)
//                    
//                    expect(realm.objects(Rate.self).count) == 33
//                    
//                    let baseObject = realm.objects(Rate.self).filter("title LIKE 'EUR'").first
//                    expect(baseObject?.isBase).to(equal(true), description: "EUR must been base currency")
//                    expect(rateUseCaseMock.ratesCalled).to(equal(true), description: "should reload call rates fetch")
//                }
                
//                context("user interactive with rates list") {
//                    it("should call rates fetch after change amount") {
//                        let baseAmt = BehaviorRelay<String?>(value: "1")
//
//                        let input = self.createInput(pollingStart: Observable.just(()),
//                                                     selection: Observable.just(nil),
//                                                     baseAmt: baseAmt)
//                        let output = sut.transform(input: input)
//
//                        output.rates
//                            .drive()
//                            .disposed(by: disposeBag!)
//
//                        output.error
//                            .drive()
//                            .disposed(by: disposeBag!)
//
//                        output.pollingTumbler
//                            .drive()
//                            .disposed(by: disposeBag!)
//
//                        _ = input.pollingStart.do()
//
//                        baseAmt.accept("2")
//                        expect(rateUseCaseMock.ratesCalled).to(equal(true), description: "should reload call rates fetch")
//                    }
                
//                    it("select textField snd move it to the top of the tableView") {
//                    }
//                }
            }
        }
    }
    
    private func createInput(
//        pollingStart: Observable<Void> = Observable.never(),
//        pollingStop: Observable<Void> = Observable.never(),
        selection: Observable<RateCellViewModel?> = Observable.just(nil),
        scheduler: SchedulerType,
        baseAmt: BehaviorRelay<String?> = BehaviorRelay<String?>(value: "1"))
        -> RatesViewModel.Input {
            return RatesViewModel.Input(
//                pollingStart: pollingStart,
//                pollingStop: pollingStop,
                selection: selection,
                scheduler: scheduler)
    }
    
    private func clearRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}

