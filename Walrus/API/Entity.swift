//
//  Entity.swift
//  Walrus
//
//  Created by Aurélien on 28/11/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Entity {

    let sprite: Sprite
    var x = 0.0, y = 0.0
    var previousX = 0, previousY = 0

    init(sprite: Sprite) {
        self.sprite = sprite
    }

    func update(game: Game) {
        let newX = Int(self.x), newY = Int(self.y)

        if newX == self.previousX && newY == self.previousY {
            return
        }

        // TODO: Calculate which rectangle changed
        let x1 = min(0, 0)
        let x2 = max(0, 1)
        let y1 = min(0, 0)
        let y2 = max(0, 1)

        let rect = CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)

        self.previousX = newX
        self.previousY = newY

        game.render(rect: rect)
    }

}

