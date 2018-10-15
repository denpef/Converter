//
//  RateItemViewModel.swift
//  GithubRatesSurfing
//
//  Created by Денис Ефимов on 03.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxRealm
import RealmSwift
import RxDataSources

class RateCellViewModel {
    
    private var disposeBag = DisposeBag()
    var total: Variable<String?> = Variable<String?>(nil)
    var rate: Rate
    let realm: Realm
    var isBase: Bool {
        if let base = realm.objects(Rate.self).filter("isBase = true").first {
            return base.title == self.rate.title
        }
        return false
    }
    
    lazy var title: Driver<String> = {
        return Driver.just(self.rate.title)
    }()
    
    lazy var description: Driver<String?> = {
        return Driver.just(NSLocale.current.localizedString(forCurrencyCode: rate.title))
    }()
    
    required init(rate: Rate, baseAmt: String?) {
        self.rate = rate
        
        realm = try! Realm()
        
        if isBase {
            self.total.value = baseAmt
            return
        }
        
        guard let amtStrong = baseAmt else {
            self.total.value = "0.0"
            return
        }
        guard let baseNumber = Float(amtStrong.replacingOccurrences(of: ",", with: ".")) else {
            self.total.value = "0.0"
            return
        }
        self.total.value = String(format: "%.2f", baseNumber * self.rate.ratio)
    }
    
}

//class RateCellViewModel {
//
//    private let realm: Realm
//    private var disposeBag = DisposeBag()
//
//    var isBase: Bool {
//        if let base = realm.objects(Rate.self).filter("isBase = true").first {
//            return base.title == self.rate.title
//        }
//        return false
//    }
//
//    var baseAmt: Variable<String?>
//    var total: Variable<String?> = Variable<String?>(nil)
//
//    var rate: Rate
//
//    lazy var title: Driver<String> = {
//        return Driver.just(self.rate.title)
//    }()
//
//    lazy var description: Driver<String?> = {
//        return Driver.just(NSLocale.current.localizedString(forCurrencyCode: rate.title))
//    }()
//
//    required init(rate: Rate, baseAmt: Variable<String?>) {
//        self.rate = rate
//        self.realm = try! Realm()
//        self.baseAmt = baseAmt
//        addObservers()
//    }
//
//    fileprivate func calculate(_ amt: String?) {
//        guard let amtStrong = amt else {
//            self.total.value = "0.0"
//            return
//        }
//        guard let baseNumber = Float(amtStrong.replacingOccurrences(of: ",", with: ".")) else {
//            self.total.value = "0.0"
//            return
//        }
//        if self.isBase {
//            self.total.value = amtStrong
//        } else {
//            self.total.value = String(format: "%.2f", baseNumber * self.rate.ratio)
//        }
//    }
//
////    fileprivate func configureWithNoUserAmount() {
////        if self.isBase {
////            self.total.value = nil
////        } else {
////            self.total.value = Rate.numberFormatter.string(from: rate.ratio as NSNumber)
////        }
////    }
//
//    private func addObservers() {
//
//        self.baseAmt.asObservable()
//            .subscribe(onNext: { (amount) in
////                guard let amount = amount else {
////                    self.total.value = nil
////                    return
////                }
//                self.calculate(amount)
//            }).disposed(by: disposeBag)
//
//        let query = realm.objects(Rate.self).filter("title LIKE '\(rate.title)'")
//
//        Observable.collection(from: query).subscribe(onNext: { (results) in
//            guard let rate = results.first else { return }
//            self.rate = rate
////            guard let amount = self.baseAmt.value else {
////                self.configureWithNoUserAmount()
////                return
////            }
//            self.calculate(self.baseAmt.value)
//        }).disposed(by: disposeBag)
//    }
//
//}

//class RateItemViewModel {
//
//    let disposeBag = DisposeBag()
//    var rate: Rate
//
//    var baseAmt: Variable<String>
//    var total: Variable<String>
//
//    required init(rate: Rate, baseAmt: Variable<String>) {
//
//        self.rate = rate
//        self.baseAmt = baseAmt
//
//        addObservers()
//
//    }
//
//    func addObservers() {
//
//        guard let realm = try? Realm() else { return }
//
//        let query = realm.objects(Rate.self).filter("title LIKE '\(rate.title)'")
//
//        Observable.collection(from: query).subscribe(onNext: { (results) in
//            guard let rate = results.first else { return }
//
//            self.rate = rate
//
//            //            guard let amount = self.userAmount.value else {
//            //                self.configureWithNoUserAmount()
//            //                return
//            //            }
//
//            // self.calculate(self.baseAmt.value)
//        }).disposed(by: disposeBag)
//
//        _ = baseAmt.asObservable()
//            .subscribe(onNext: { amt in
//                if let baseNumber = Float(amt) {
//                    self.total.value = String(format: "%.2f", baseNumber * self.rate.ratio)
//                }
//            })
//
//    }
//
////    fileprivate func calculate(_ amount: String) {
////        let newAmount = amount
////        let userNumber = Float(newAmount) ?? 0
//////        if self.isBase {
//////            self.valueString.value = Rate.numberFormatter.string(from: userNumber as NSNumber)
//////        } else {
////            let convertedValue = userNumber * self.rate.ratio
////            self.valueString.value = Rate.numberFormatter.string(from: convertedValue as NSNumber)
////        //}
////    }
////
//}
