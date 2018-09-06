//
//  Grid.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

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
        let height = frame.height / CGFloat(size.rows)
        for i in 0 ..< size.rows {
            let row = Row(capacity: size.columns, frame: CGRect(x: 0, y: CGFloat(i) * height, width: frame.width, height: height))
            row.delegate = self
            rows.insert(row, at: i)
        }

        rows.append(Row(capacity: size.columns, frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: height), available: false))
    }
}

extension Grid: RowDelegate {
    func shouldRemoveRow(_ row: Row) {
        for block in row.blocks {
            block.removeFromSuperview()
        }

        guard let index = rows.index(of: row) else { return }
        let item = rows.remove(at: index)

        delegate?.grid(self, didRemove: item)
    }
}






