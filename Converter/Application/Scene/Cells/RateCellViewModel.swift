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
    
    var total: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
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
            self.total.accept(baseAmt)
            return
        }
        
        guard let amtStrong = baseAmt else {
            self.total.accept("0.0")
            return
        }
        guard let baseNumber = Float(amtStrong.replacingOccurrences(of: ",", with: ".")) else {
            self.total.accept("0.0")
            return
        }
        self.total.accept(String(format: "%.2f", baseNumber * self.rate.ratio))
    }
    
}
