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

class Grid {

    var cellSize: CGSize
    var rows = [Row]()
    var size: GridSize
    var frame: CGRect

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

        let offset = frame.height - cellSize.height * CGFloat(size.rows)

        for i in 0 ..< size.rows {
            let row = Row(capacity: size.columns, frame: CGRect(x: 0, y: offset + CGFloat(i) * cellSize.height, width: frame.width, height: cellSize.height))
            row.delegate = self
            rows.insert(row, at: i)
        }

        rows.append(Row(capacity: size.columns, frame: CGRect(x: 0, y: offset + CGFloat(rows.count) * cellSize.height, width: frame.width, height: cellSize.height), available: false))
    }
}

extension Grid: RowDelegate {
    func shouldRemoveRow(_ row: Row) {
        for block in row.blocks {
            block.removeFromSuperview()
        }

        guard let index = rows.index(of: row) else { return }
        let removed = rows.remove(at: index)

        for i in 0 ..< index {
            rows[i].frame.origin.y += cellSize.height
            rows[i].updateBlockFrames()
        }

        let row = Row(capacity: size.columns, frame: CGRect(x: 0, y: 0, width: frame.width, height: cellSize.height))
        row.delegate = self
        rows.insert(row, at: 0)
    }
}






