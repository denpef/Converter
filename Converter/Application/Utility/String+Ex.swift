//
//  String+Ex.swift
//  Converter
//
//  Created by Денис Ефимов on 10.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import Foundation

extension String {
    var isDigits: Bool {
        var charSet = CharacterSet.decimalDigits.inverted
        charSet.remove(",")
        return !isEmpty && rangeOfCharacter(from: charSet) == nil
    }
}
