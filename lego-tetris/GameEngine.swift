//
//  ViewController.swift
//  lego-tetris
//
//  Created by Granheim Brustad , Henrik on 06/09/2018.
//  Copyright © 2018 Henrik Brustad. All rights reserved.
//

import UIKit

class GameEngine: UIViewController {

    lazy var timer = CADisplayLink(target: self, selector: #selector(step(timer:)))
    lazy var game = GameViewController(frame: CGRect(x: 0, y: 88, width: view.frame.width, height: view.frame.height - (88 + 83)))

    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let imageView = UIImageView(image: #imageLiteral(resourceName: "background"))
        imageView.frame = view.frame
        view.addSubview(imageView)

        // Add game view controller
        addChildViewController(game)
        view.addSubview(game.view)
        game.didMove(toParentViewController: self)
        game.engine = self

        // Start timer
        timer.add(to: .current, forMode: .defaultRunLoopMode)
    }

    @objc func step(timer: CADisplayLink) {
        game.update(with: timer)
    }

}

