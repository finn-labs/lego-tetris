//
//  GameViewController.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var blocks: Set<LegoBlock> = []
    var grid: Grid!

    // testing
    var previousTime = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        grid = Grid(size: GridSize(rows: 12, columns: 10), frame: view.frame)
        grid.delegate = self
    }

    func update(timer: CADisplayLink) {

        if timer.timestamp - previousTime > 2 {
            newBlock(at: Int(arc4random_uniform(UInt32(grid.size.columns))))
            previousTime = timer.timestamp
        }

        for block in blocks {
            block.update(timer: timer)
        }
    }
}

extension GameViewController: GridDelegate {
    func grid(_ grid: Grid, didRemove row: Row) {
        for block in row.blocks {
            self.blocks.remove(block)
        }
    }
}

private extension GameViewController {
    func newBlock(at column: Int) {
        let block = LegoBlock(size: 4, cellSize: grid.cellSize)
        block.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: view.frame.minY - grid.cellSize.height)
        block.backgroundColor = UIColor(hue: CGFloat(arc4random()) / CGFloat(UInt32.max), saturation: 0.3, brightness: 0.6, alpha: 1.0)
        view.addSubview(block)
        blocks.insert(block)
    }
}
