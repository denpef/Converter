//
//  ResponseWrapper.swift
//  Domain
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//
import RealmSwift

class RatesWrapper: Decodable {

    typealias RatesDictionary = [String: Float]

    var base: String = ""
    var date = Date(timeIntervalSinceNow: 0)

    //var rates = List<Rate>()
    var rates = [Rate]()

    enum CodingKeys: String, CodingKey {
        case base
        case date
        case rates = "rates"
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        base = try container.decode(String.self, forKey: .base)
        date = try container.decode(Date.self, forKey: .date)

        if let items = try? container.decode(RatesDictionary.self, forKey: .rates) {

            for item in items {
                do {
                    let realm = try Realm()
                    try realm.write {
                        rates.append(Rate(title: item.key, ratio: item.value, isBase: false))
                        let currentRate: [String: Any] = ["title": item.key,
                                                            "ratio": item.value,
                                                            "isBase": false]
                        rates.append(realm.create(Rate.self, value: currentRate, update: true))
                    }
                } catch {
                    debugPrint("init wrapper: \(error.localizedDescription)")
                }
            }

            do {
                let realm = try Realm()
                try realm.write {
                    let currentRate: [String: Any] = ["title": base,
                                                        "ratio": 1.0,
                                                        "isBase": true]
                    rates.insert(realm.create(Rate.self, value: currentRate, update: true), at: 0)
                }
            } catch {
                debugPrint("init wrapper: \(error.localizedDescription)")
            }
        }
    }
}
