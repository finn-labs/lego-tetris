//
//  GameViewController.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var grid: Grid!

    // testing
    var previousTime = 0.0

    var currentBlock: LegoBlock?
    var currentColumn: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        grid = Grid(size: GridSize(rows: 12, columns: 10), frame: view.frame)
        grid.delegate = self

        currentColumn = 3
        currentBlock = newBlock(at: currentColumn!)
    }

    func update(with timer: CADisplayLink) {

//        if timer.timestamp - previousTime > 2 {
//            newBlock(at: Int(arc4random_uniform(UInt32(grid.size.columns))))
//            previousTime = timer.timestamp
//        }

//        for block in blocks {
//            block.update(timer: timer)
//        }

        guard let block = currentBlock, let column = currentColumn else { return }
        block.update(with: timer)
        guard let row = grid.availableRow(for: block, at: column) else { return }

        if block.frame.minY >= row.frame.minY {
            row.add(block, at: column)
            block.velocity = .zero
            let c = randomColumn()
            currentBlock = newBlock(at: c)
            currentColumn = c
        }
    }
}

extension GameViewController: GridDelegate {
    func grid(_ grid: Grid, didRemove row: Row) {
        print("Removed row:", row.frame)
    }
}

private extension GameViewController {
    func randomColumn() -> Int {
        let upper = UInt32(grid.size.columns - 4)
        return Int(arc4random_uniform(upper))
    }

    func newBlock(at column: Int) -> LegoBlock {
        let block = LegoBlock(size: 4, cellSize: grid.cellSize)
        block.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: grid.frame.minY - grid.cellSize.height)
        block.backgroundColor = UIColor(hue: CGFloat(arc4random()) / CGFloat(UInt32.max), saturation: 0.3, brightness: 0.6, alpha: 1.0)
        view.addSubview(block)
        return block
    }
}
