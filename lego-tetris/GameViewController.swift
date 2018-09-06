//
//  GameViewController.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

class Constants {
    static let unitSize: CGFloat = 10
}

class GameViewController: UIViewController {

    var blocks: Set<LegoBlock> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    @objc func handleTap() {
        let block = LegoBlock(size: 2)
        block.position = CGPoint(x: view.frame.maxX / 2, y: view.frame.height / 2)
        block.backgroundColor = UIColor(hue: 0.6, saturation: 0.3, brightness: 0.6, alpha: 1.0)
        view.addSubview(block)
        blocks.insert(block)
    }

    func update(timer: CADisplayLink) {
        for block in blocks {
            block.update(timer: timer)
        }
    }
}
