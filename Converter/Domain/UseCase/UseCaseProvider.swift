//
//  UseCaseProvider.swift
//  Domain
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation

public protocol UseCaseProvider {

    func makeRatesUseCase() -> RateUseCase

}
