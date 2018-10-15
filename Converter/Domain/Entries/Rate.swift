//
//  Rate.swift
//  Domain
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import RealmSwift

public class Rate: RealmSwift.Object, Decodable {

    @objc dynamic var title: String = ""
    @objc dynamic var ratio: Float = 0
    @objc dynamic var isBase: Bool = false

    enum CodingKeys: String, CodingKey {
        case title = "id"
        case ratio = "ratio"
    }

    convenience init(title: String, ratio: Float, isBase: Bool) {
        self.init()

        self.title = title
        self.ratio = ratio
        self.isBase = isBase

    }

    override public static func primaryKey() -> String? {
        return "title"
    }

    override public static func indexedProperties() -> [String] {
        return ["title"]
    }
}
