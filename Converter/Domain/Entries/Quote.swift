////
////  Quote.swift
////  Domain
////
////  Created by Денис Ефимов on 04.10.2018.
////  Copyright © 2018 Denis Efimov. All rights reserved.
////
//
//import RealmSwift
//
//class Quote: RealmSwift.Object, Decodable {
//
//    @objc dynamic var id: String = ""
//    @objc dynamic var value: Float = 0
//    @objc dynamic var isBase: Bool = false
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case value
//    }
//
//    convenience init(id: String, value: Float) {
//        self.init()
//
//        self.id = id
//        self.value = value
//
//    }
//
//    override static func primaryKey() -> String? {
//        return "id"
//    }
//
//    override static func indexedProperties() -> [String] {
//        return ["id"]
//    }
//}
//
//extension Quote {
//    public static let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.currencyCode = ""
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//
//        return formatter
//    }()
//
//    public static let sortDescriptors: [SortDescriptor] = {
//        return [
//            SortDescriptor(keyPath: "isBase", ascending: false),
//            SortDescriptor(keyPath: "id", ascending: true)
//        ]
//    }()
//}
