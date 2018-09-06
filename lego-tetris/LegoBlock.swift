//
//  LegoBlock.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

class LegoBlock: UIView {

    let size: CGFloat
    var velocity = CGVector(dx: 0, dy: 2)

    override var backgroundColor: UIColor? {
        didSet {
            for view in subviews {
                view.backgroundColor = backgroundColor
            }
        }
    }

    var position: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }

    init(size: CGFloat, cellSize: CGSize) {
        self.size = size
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: size * cellSize.width, height: cellSize.height)))

        let unit = cellSize.width / 5.0

        for i in 0 ..< Int(size) {
            let frame = CGRect(x: CGFloat(i) * cellSize.width + unit, y: -unit, width: 3 * unit, height: unit)
            let stud = UIView(frame: frame)
            addSubview(stud)
        }
    }

    func update(with timer: CADisplayLink) {
        removeIfNeeded()

        frame.origin.x += velocity.dx
        frame.origin.y += velocity.dy
    }

    private func removeIfNeeded() {
        guard let superview = superview else { return }
        if frame.origin.y > superview.frame.maxY {
            removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
