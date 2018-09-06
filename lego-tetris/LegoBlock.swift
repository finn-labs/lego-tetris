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
    let velocity = CGVector(dx: 0, dy: 2)

    var position: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }

    init(size: CGFloat) {
        self.size = size
        let width = (2 + 2 * size - 1) * Constants.unitSize
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 5.0 * Constants.unitSize)))
    }

    func update(timer: CADisplayLink) {
        frame.origin.x += velocity.dx
        frame.origin.y += velocity.dy
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
