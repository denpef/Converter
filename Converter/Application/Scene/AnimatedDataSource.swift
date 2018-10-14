//
//  AnimatedDataSource.swift
//  Converter
//
//  Created by Денис Ефимов on 10.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import RxDataSources

extension TickerItemViewModel: Equatable {
    
    static func == (lhs: TickerItemViewModel, rhs: TickerItemViewModel) -> Bool {
        let result = lhs.valueString.value == rhs.valueString.value
            && lhs.ticker.title == rhs.ticker.title
        return result
    }
    
}

extension TickerItemViewModel: IdentifiableType {
    typealias Identity = String

    var identity: String {
        return ticker.title
    }
}

struct TickersItemSection {
    var header: String?

    var items: [TickerItemViewModel]

    init(header: String? = nil, items: [TickerItemViewModel]) {
        self.items = items
        self.header = header
    }
}

extension TickersItemSection: AnimatableSectionModelType {

    typealias Item = TickerItemViewModel
    typealias Identity = String

    var identity: String {
        return header ?? ""
    }

    init(original: TickersItemSection, items: [Item]) {
        self = original
        self.items = items
    }
}

extension TickersItemSection: Equatable {

    static func == (lhs: TickersItemSection, rhs: TickersItemSection) -> Bool {
        return lhs.header == rhs.header && lhs.items == rhs.items
    }

}
