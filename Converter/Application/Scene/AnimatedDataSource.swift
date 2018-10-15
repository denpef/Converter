//
//  AnimatedDataSource.swift
//  Converter
//
//  Created by Денис Ефимов on 10.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import RxDataSources

extension RateCellViewModel: Equatable {
    
    static func == (lhs: RateCellViewModel, rhs: RateCellViewModel) -> Bool {
        let result = (lhs.rate.isBase || lhs.total.value == rhs.total.value)
            && lhs.rate.ratio == rhs.rate.ratio
            && lhs.rate.title == rhs.rate.title
        return result
    }
    
}

extension RateCellViewModel: IdentifiableType {
    typealias Identity = String

    var identity: String {
        return rate.title
    }
}

struct RatesItemSection {
    var header: String?

    var items: [RateCellViewModel]

    init(header: String? = nil, items: [RateCellViewModel]) {
        self.items = items
        self.header = header
    }
}

extension RatesItemSection: AnimatableSectionModelType {

    typealias Item = RateCellViewModel
    typealias Identity = String

    var identity: String {
        return header ?? ""
    }

    init(original: RatesItemSection, items: [Item]) {
        self = original
        self.items = items
    }
}

extension RatesItemSection: Equatable {

    static func == (lhs: RatesItemSection, rhs: RatesItemSection) -> Bool {
        return lhs.header == rhs.header
    }

}
