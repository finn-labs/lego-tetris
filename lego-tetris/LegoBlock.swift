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
    var velocity = CGVector.zero
    var scoreMultiplier: CGFloat = 1

    private let radius: CGFloat = 2.0

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

        layer.cornerRadius = radius

        let unit = cellSize.width / 5.0
        for i in 0 ..< Int(size) {
            let frame = CGRect(x: CGFloat(i) * cellSize.width + unit, y: -unit, width: 3 * unit, height: unit)
            let stud = UIView(frame: frame)
            stud.layer.cornerRadius = radius
            stud.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            addSubview(stud)
        }
    }

    func update(with timer: CADisplayLink) {
        frame.origin.x += velocity.dx
        frame.origin.y += velocity.dy
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
