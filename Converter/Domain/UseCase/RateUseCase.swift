//
//  RateUseCase.swift
//  Domain
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation
import RxSwift

public protocol RateUseCase {

    func rates(baseCurrency: String) -> Observable<[Rate]>

}
