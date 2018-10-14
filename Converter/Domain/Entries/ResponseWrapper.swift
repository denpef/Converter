//
//  ResponseWrapper.swift
//  Domain
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//
import RealmSwift

class ResponseWrapper: Decodable {

    typealias TickersDictionary = [String: Float]

    var base: String = ""
    var date = Date(timeIntervalSinceNow: 0)

    //var tickers = List<Ticker>()
    var tickers = [Ticker]()

    enum CodingKeys: String, CodingKey {
        case base
        case date
        case tickers = "rates"
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        base = try container.decode(String.self, forKey: .base)
        date = try container.decode(Date.self, forKey: .date)

        if let items = try? container.decode(TickersDictionary.self, forKey: .tickers) {

            for item in items {
                do {
                    let realm = try Realm()
                    try realm.write {
                        tickers.append(Ticker(title: item.key, value: item.value, isBase: false))
                        let currentTicker: [String: Any] = ["title": item.key,
                                                            "value": item.value,
                                                            "isBase": false]
                        tickers.append(realm.create(Ticker.self, value: currentTicker, update: true))
                    }
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }

            do {
                let realm = try Realm()
                try realm.write {
                    let currentTicker: [String: Any] = ["title": base,
                                                        "value": 1.0,
                                                        "isBase": true]
                    tickers.insert(realm.create(Ticker.self, value: currentTicker, update: true), at: 0)
                    print("2: \(Thread.current)")
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
