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

    var currentBlock: LegoBlock?
    var currentColumn: Int?
    var initialPosition: CGPoint = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(panGesture)

        grid = Grid(size: GridSize(rows: 15, columns: 10), frame: view.frame)
        grid.delegate = self

        currentBlock = newBlock()
    }

    func update(with timer: CADisplayLink) {

        guard let block = currentBlock, let column = currentColumn else { return }
        block.update(with: timer)

        guard let row = grid.availableRow(for: block, at: column) else { return }

        if block.frame.minY >= row.frame.minY {
            row.add(block, at: column)
            block.position.y = row.frame.minY
            block.velocity = .zero
            currentBlock = newBlock()
        }
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let block = currentBlock else { return }

        if gesture.state == .began {
            initialPosition = block.position
        }

        let translation = gesture.translation(in: view)
        let currentPosition = CGPoint(x: initialPosition.x + translation.x, y: initialPosition.y + translation.y)

        let column = self.column(for: currentPosition)
        guard column + Int(block.size) <= grid.size.columns, column >= 0 else { return }
        guard column != currentColumn else { return }

        currentColumn = column
        block.position.x = CGFloat(column) * grid.cellSize.width
    }
}

extension GameViewController: GridDelegate {
    func grid(_ grid: Grid, didRemove row: Row) {
        print("Removed row:", row.frame)
    }
}

private extension GameViewController {
    func column(for position: CGPoint) -> Int {
        return Int(position.x / grid.cellSize.width)
    }

    func randomColumn(for block: LegoBlock) -> Int {
        let upper = UInt32(grid.size.columns - Int(block.size))
        return Int(arc4random_uniform(upper))
    }

    func newBlock() -> LegoBlock {
        let block = LegoBlock(size: 1 + CGFloat(arc4random_uniform(4)), cellSize: grid.cellSize)
        let column = randomColumn(for: block)
        currentColumn = column

        block.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: grid.frame.minY - grid.cellSize.height)
        block.backgroundColor = UIColor(hue: CGFloat(arc4random()) / CGFloat(UInt32.max), saturation: 0.3, brightness: 0.6, alpha: 1.0)

        view.addSubview(block)
        return block
    }
}
