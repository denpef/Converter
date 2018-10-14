//
//  ViewModelType.swift
//  GithubTickersSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
