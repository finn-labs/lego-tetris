//
//  Row.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

protocol RowDelegate: class {
    func shouldRemoveRow(_ row: Row)
}

class Row {

    private var capacity: Int
    private var size: CGFloat = 0
    private var available: [Bool]

    var frame: CGRect
    var blocks: Set<LegoBlock> = []
    weak var delegate: RowDelegate?

    init(capacity: Int, frame: CGRect, available: Bool = true) {
        self.capacity = capacity
        self.frame = frame
        self.available = Array<Bool>(repeating: available, count: capacity)
    }

    func isAvailable(for block: LegoBlock, at column: Int) -> Bool {
        for i in column ..< column + Int(block.size) {
            if !available[i] { return false }
        }
        return true
    }

    func add(_ block: LegoBlock, at column: Int) {
        blocks.insert(block)
        size += block.size

        for i in column ..< column + Int(block.size) {
            available[i] = false
        }

        if size >= CGFloat(capacity) {
            delegate?.shouldRemoveRow(self)
        }
    }

    func updateBlockFrames() {
        for block in blocks {
            block.position.y = frame.minY
        }
    }
}

extension Row: Equatable {
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.blocks == rhs.blocks
    }
}
