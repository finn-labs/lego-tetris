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
    var score = Score()

    var currentBlock: LegoBlock?
    var nextBlock: LegoBlock?

    var currentColumn: Int?
    var initialPosition: CGPoint = .zero

    private var panGesture: UIPanGestureRecognizer?
    private var swipeGesture: UISwipeGestureRecognizer?
    private var frame: CGRect

    private lazy var scoreLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(frame: CGRect) {
        self.frame = frame
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: frame)
        view.backgroundColor = UIColor(hue: 0.6, saturation: 0.3, brightness: 0.8, alpha: 0.3)

        view.addSubview(scoreLabel)
        let constraints = [
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGesture?.delegate = self
        view.addGestureRecognizer(panGesture!)

        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeGesture!.direction = .down
        view.addGestureRecognizer(swipeGesture!)

        grid = Grid(size: GridSize(rows: 15, columns: 10), frame: view.frame)

        currentBlock = newBlock()
        currentBlock?.velocity = CGVector(dx: 0, dy: 2)
        currentColumn = (grid.size.columns - Int(currentBlock!.size)) / 2
        nextBlock = newBlock(next: true)
    }

    func update(with timer: CADisplayLink) {

        guard let block = currentBlock, let column = currentColumn else { return }
        block.update(with: timer)

        guard let row = grid.availableRow(for: block, at: column) else { return }

        if block.frame.minY >= row.frame.minY {
            block.position.y = row.frame.minY
            block.velocity = .zero

            guard row.add(block, at: column) else {
                setupNewBlock()
                return
            }

            score.update(withMultipler: Double(block.scoreMultiplier))
            scoreLabel.text = String(Int(score.value))

            setupNewBlock(success: true)
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

    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        guard let block = currentBlock, let column = currentColumn else { return }
        guard let row = grid.availableRow(for: block, at: column) else { return }
        block.position.y = row.frame.minY
    }
}

extension GameViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = panGesture, pan == gestureRecognizer else { return false }
        return true
    }
}

private extension GameViewController {
    func column(for position: CGPoint) -> Int {
        return Int(position.x / grid.cellSize.width)
    }

    func setupNewBlock(success: Bool = false) {
        guard let current = currentBlock, let next = nextBlock else { return }
        next.transform = .identity

        let column = (grid.size.columns - Int(next.size)) / 2
        currentColumn = column

        next.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: grid.frame.minY - grid.cellSize.height)
        next.velocity = CGVector(dx: 0, dy: 2)
        next.scoreMultiplier = success ? current.scoreMultiplier + 1 : 1

        currentBlock = next
        nextBlock = newBlock(next: true)
    }

    func newBlock(next: Bool = false) -> LegoBlock {
        let block = LegoBlock(size: 1 + CGFloat(arc4random_uniform(4)), cellSize: grid.cellSize)

        if next {
            let scale: CGFloat = 0.43
            block.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            block.position = CGPoint(x: frame.maxX - 8 - block.frame.width, y: 24)
        } else {
            let column = (grid.size.columns - Int(block.size)) / 2
            block.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: grid.frame.minY - grid.cellSize.height)
        }

        block.backgroundColor = UIColor(hue: CGFloat(arc4random()) / CGFloat(UInt32.max), saturation: 0.3, brightness: 0.8, alpha: 1.0)

        view.addSubview(block)
        return block
    }
}
