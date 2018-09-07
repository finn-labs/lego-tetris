//
//  Score.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 07/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import Foundation

class Score {

    var value = 0.0
    private let baseValue = 10.0

    func update(withMultipler mult: Double) {
        let newValue = baseValue * mult
        value += newValue
    }
}
