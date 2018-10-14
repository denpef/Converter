//
//  TickerItemViewModel.swift
//  GithubTickersSurfing
//
//  Created by Денис Ефимов on 03.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

//struct TickerItemViewModel   {
//
//    let ticker: Ticker
//    let title:String
//    var percentChange: String?
//    var highestBid: String?
//
//
//    init (with ticker: Ticker) {
//        self.ticker = ticker
//        self.title = ticker.title ?? "--"
//        if let quote = ticker.quote {
//            self.percentChange = quote.percentChange
//            self.highestBid = quote.highestBid
//        }
//
//    }
//
//}

import Foundation
import RxCocoa
import RxSwift
import RxRealm
import RealmSwift
import RxDataSources

class TickerItemViewModel {

    private let realm: Realm

    private var disposeBag: DisposeBag

    var isBase: Bool {
        if let base = realm.objects(Ticker.self).filter("isBase = true").first {
            return base.title == self.ticker.title
        }

        return false
    }

    var userAmount: Variable<String>
    var valueString: Variable<String?> = Variable<String?>(nil)

    var ticker: Ticker

    lazy var title: Driver<String> = {
        return Driver.just(self.ticker.title)
    }()

    lazy var subtitle: Driver<String?> = {
        let currencyId = ticker.title
        let locale = NSLocale.current

        return Driver.just( locale.localizedString(forCurrencyCode: currencyId) )
    }()

    lazy var countryCode: Driver<String?> = {
        let currencyId = ticker.title

        if currencyId == "EUR" {
            return Driver.just("EU")
        }

        let locales = Locale.availableIdentifiers.map(Locale.init)

        let localesWithCode = locales.filter { locale in
            locale.currencyCode == currencyId
        }
        let set = Set(localesWithCode)

        if let country = set.first?.identifier.components(separatedBy: "_").last {
            return Driver.just( country )
        }

        return Driver.just( nil )
    }()

    required init(ticker: Ticker, userAmount: Variable<String>) {

        self.ticker = ticker
        self.realm = try! Realm()
        self.userAmount = userAmount
        self.disposeBag = DisposeBag()
        addObservers()

    }

    fileprivate func calculate(_ amount: String) {
        let newAmount = amount.replacingOccurrences(of: ",", with: ".")
        let userNumber = Float(newAmount) ?? 0
        if self.isBase {
            self.valueString.value = Ticker.numberFormatter.string(from: userNumber as NSNumber)
        } else {

            let convertedValue = userNumber * self.ticker.value
            self.valueString.value = Ticker.numberFormatter.string(from: convertedValue as NSNumber)
        }
    }

    fileprivate func configureWithNoUserAmount() {
        if self.isBase {
            self.valueString.value = nil
        } else {
            self.valueString.value = Ticker.numberFormatter.string(from: ticker.value as NSNumber)
        }
    }

    private func addObservers() {

        self.userAmount.asObservable()
            .subscribe(onNext: { (amount) in
//                guard let amount = amount else {
//                    self.valueString.value = nil
//                    return
//                }
                self.calculate(amount)
            }).disposed(by: disposeBag)

        let query = realm.objects(Ticker.self).filter("title LIKE '\(ticker.title)'")

        Observable.collection(from: query).subscribe(onNext: { (results) in
            guard let ticker = results.first else { return }

            self.ticker = ticker

//            guard let amount = self.userAmount.value else {
//                self.configureWithNoUserAmount()
//                return
//            }

            self.calculate(self.userAmount.value)
        }).disposed(by: disposeBag)
    }

}
