//
//  GameViewController.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

extension UIColor {
    static let primaryBlue = UIColor(red: 0/255, green: 99/255, blue: 251/255, alpha: 1.0)
    static let secondaryBlue = UIColor(red: 6/255, green: 190/255, blue: 251/255, alpha: 1.0)
    static let stone = UIColor(red: 118/255, green: 118/255, blue: 118/255, alpha: 1.0)
    static let sardine = UIColor(red: 195/255, green: 204/255, blue: 217/255, alpha: 1.0)
}

class GameViewController: UIViewController {

    let colors: [UIColor] = [.primaryBlue, .secondaryBlue, .stone, .sardine]

    var grid: Grid!
    var score = Score()

    var currentBlock: LegoBlock?
    var nextBlock: LegoBlock?

    var currentColumn: Int?
    var initialPosition: CGPoint = .zero

    private var panGesture: UIPanGestureRecognizer?
    private var swipeGesture: UISwipeGestureRecognizer?
    private var frame: CGRect
    private lazy var gameOverView = createGameOverView()

    weak var engine: GameEngine?

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
        view.backgroundColor = .clear
        view.clipsToBounds = true

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

        grid = Grid(size: GridSize(rows: 14, columns: 10), frame: view.frame)

        currentBlock = newBlock()
        currentBlock?.velocity = CGVector(dx: 0, dy: 2)
        currentColumn = (grid.size.columns - Int(currentBlock!.size)) / 2
        nextBlock = newBlock(next: true)
    }

    func update(with timer: CADisplayLink) {

        guard let block = currentBlock, let column = currentColumn else { return }
        block.update(with: timer)

        guard let row = grid.availableRow(for: block, at: column) else {
            timer.isPaused = true
            presentGameOver()
            return
        }

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

        next.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: -grid.cellSize.height)
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
            block.position = CGPoint(x: grid.cellSize.width * CGFloat(column), y: -grid.cellSize.height)
        }

        block.backgroundColor = colors[Int(arc4random_uniform(4))]

        view.addSubview(block)
        return block
    }

    func presentGameOver() {
        view.addSubview(gameOverView)
        NSLayoutConstraint.activate([
            gameOverView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameOverView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gameOverView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
    }

    func createGameOverView() -> UIView {

        let goView = UIView(frame: .zero)
        goView.layer.cornerRadius = 32
        goView.clipsToBounds = true
        goView.translatesAutoresizingMaskIntoConstraints = false

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        goView.addSubview(blurView)

        let label = UILabel(frame: .zero)
        label.text = "Wooops"
        label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        goView.addSubview(label)

        let slabel = UILabel(frame: .zero)
        let intVal = Int(score.value)
        slabel.text = "Score: \(intVal)"
        slabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        slabel.textColor = .darkGray
        slabel.translatesAutoresizingMaskIntoConstraints = false
        goView.addSubview(slabel)

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(startOver), for: .touchUpInside)
        button.setTitle("Prøv Igjen", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        button.translatesAutoresizingMaskIntoConstraints = false
        goView.addSubview(button)

        let constraints = [
            blurView.leadingAnchor.constraint(equalTo: goView.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: goView.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: goView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: goView.bottomAnchor),

            label.centerXAnchor.constraint(equalTo: goView.centerXAnchor),
            label.topAnchor.constraint(equalTo: goView.topAnchor, constant: 32),

            slabel.centerXAnchor.constraint(equalTo: goView.centerXAnchor),
            slabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),

            button.centerXAnchor.constraint(equalTo: goView.centerXAnchor),
            button.topAnchor.constraint(equalTo: slabel.bottomAnchor, constant: 16),

            goView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 32)
        ]

        NSLayoutConstraint.activate(constraints)

        return goView
    }

    @objc func startOver() {
        grid.clear()
        score.value = 0
        gameOverView.removeFromSuperview()
        currentBlock?.removeFromSuperview()
        nextBlock?.removeFromSuperview()

        currentBlock = newBlock()
        currentBlock?.velocity = CGVector(dx: 0, dy: 2)
        currentColumn = (grid.size.columns - Int(currentBlock!.size)) / 2
        nextBlock = newBlock(next: true)

        engine?.timer.isPaused = false
    }
    
}































