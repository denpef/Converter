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
            let endpointsClosure: MoyaProvider<APIManager>
                .EndpointClosure = { (target: APIManager) -> Endpoint in
                    let sampleResponseClosure = { () -> EndpointSampleResponse in
                        return .networkResponse(200, target.sampleData)
                    }
                    let url = URL(target: target).absoluteString
                    let endpoint = Endpoint(url: url,
                                            sampleResponseClosure: sampleResponseClosure,
                                            method: target.method,
                                            task: target.task,
                                            httpHeaderFields: target.headers)
                    return endpoint
            }
            
            let ratesProvider = MoyaProvider<APIManager>(
                endpointClosure: endpointsClosure,
                stubClosure: MoyaProvider.immediatelyStub)
            
            rateUseCaseMock = RateUseCaseMock()
            scheduler = TestScheduler(initialClock: 0)
            SharingScheduler.mock(scheduler: scheduler) {
                sut = RatesViewModel(useCase: rateUseCaseMock)
            }
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
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        describe("View Model functional") {
            context("network testing") {
//                it("should call rates response after start polling") {
//                    // arrange
//                    expect(rateUseCaseMock.ratesCalled).toNot(equal(true))
//
//                    //scheduler.start()
//
//                    scheduler.scheduleAt(400) {
//                        // assert
//                        expect(rateUseCaseMock.ratesCalled).to(equal(true), description: "should have call rates fetch")
//                    }
//
//                    //scheduler.start()
//                }
                
                it("should clean realm and put sample data from file") {
                    
                    let input = self.createInput(pollingStart: Observable.just(()),
                                                 selection: Observable.just(nil))
                    let output = sut.transform(input: input)
                    
                    output.rates
                        .drive()
                        .disposed(by: disposeBag!)
                    
                    output.error
                        .drive()
                        .disposed(by: disposeBag!)
                    
                    output.pollingTumbler
                        .drive()
                        .disposed(by: disposeBag!)
                    
                    input.pollingStart.do()
                    
                    // Realm setup and mock JSON data to database
                    let realm = try! Realm()
                    try! realm.write {
                        let all = realm.objects(Rate.self)
                        realm.delete(all)
                    }
                    
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    _ = try! decoder.decode(RatesWrapper.self, from: APIManager.getRates(base: "EUR").sampleData)
                    
                    expect(realm.objects(Rate.self).count) == 33
                    
                    let baseObject = realm.objects(Rate.self).filter("title LIKE 'EUR'").first
                    expect(baseObject?.isBase).to(equal(true), description: "EUR must been base currency")
                    expect(rateUseCaseMock.ratesCalled).to(equal(true), description: "should reload call rates fetch")
                }
                
                context("user interactive with rates list") {
                    it("should call rates fetch after change amount") {
                        sut.baseAmt.accept("2")
                        expect(rateUseCaseMock.ratesCalled).to(equal(true), description: "should reload call rates fetch")
                    }
                    
                    it("select textField snd move it to the top of the tableView") {
                    }
                }
            }
        }
    }
    
    private func createInput(
        pollingStart: Observable<Void> = Observable.never(),
        pollingStop: Observable<Void> = Observable.never(),
        selection: Observable<RateCellViewModel?> = Observable.just(nil))
        -> RatesViewModel.Input {
            return RatesViewModel.Input(
                pollingStart: pollingStart,
                pollingStop: pollingStop,
                selection: selection)
    }
    
    private func resetRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}

