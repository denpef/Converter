//
//  RateUseCaseMock.swift
//  ConverterTests
//
//  Created by Денис Ефимов on 15.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

@testable import Converter
import RxSwift

class RateUseCaseMock: RateUseCase {
    
    var ratesReturnValue: Observable<[Rate]> = Observable.just([])
    var ratesCalled = false
    
    func rates(baseCurrency: String) -> Observable<[Rate]> {
        ratesCalled = true
        debugPrint("IT CALLED \(Date())")
        return ratesReturnValue
    }
    
}
