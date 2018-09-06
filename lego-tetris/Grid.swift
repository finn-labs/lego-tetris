//
//  Grid.swift
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

    var blocks: Set<LegoBlock> = []
    weak var delegate: RowDelegate?

    init(capacity: Int, available: Bool) {
        self.capacity = capacity
        self.available = Array<Bool>(repeating: available, count: capacity)
    }

    func isAvailable(for block: LegoBlock, at column: Int) -> Bool {
        for i in column ..< column + Int(block.size) {
            if !available[i] { return false }
        }
        return true
    }

    func add(_ block: LegoBlock, at column: Int) {
        guard size + block.size > CGFloat(capacity) else {
            delegate?.shouldRemoveRow(self)
            return
        }
        blocks.insert(block)
        size += block.size

        for i in column ..< column + Int(block.size) {
            available[i] = false
        }
    }
}

extension Row: Equatable {
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.blocks == rhs.blocks
    }


}

struct GridSize {
    let rows: Int
    let columns: Int
}

protocol GridDelegate: class {
    func grid(_ grid: Grid, didRemove row: Row)
}

class Grid {

    var cellSize: CGSize
    var rows = [Row]()
    var size: GridSize
    var frame: CGRect

    weak var delegate: GridDelegate?

    init(size: GridSize, frame: CGRect) {
        self.size = size
        self.frame = frame
        let width = UIScreen.main.bounds.width / CGFloat(size.columns)
        self.cellSize = CGSize(width: width, height: width * 1.2)

        setupRows(for: size)
    }

    func availableRow(for block: LegoBlock, at column: Int) -> Row? {
        for (i, row) in rows.enumerated() {
            guard !row.isAvailable(for: block, at: column) else { continue }
            guard i > rows.startIndex else { return nil }
            let index = rows.index(before: i)
            return rows[index]
        }

        return nil
    }
}

private extension Grid {
    func setupRows(for size: GridSize) {
        for i in 0 ..< size.rows {
            let row = Row(capacity: size.columns, available: true)
            row.delegate = self
            rows.insert(row, at: i)
        }

        rows.append(Row(capacity: 0, available: false))
    }
}

extension Grid: RowDelegate {
    func shouldRemoveRow(_ row: Row) {
        guard let index = rows.index(of: row) else { return }
        let item = rows.remove(at: index)
        delegate?.grid(self, didRemove: item)
    }
}






