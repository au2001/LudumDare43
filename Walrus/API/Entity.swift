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

        var pixels: Set<Pixel> = []

        for pixel in sprite.getHitBox(threshold: 0) {
            pixels.insert(Pixel(x: pixel.x + previousX, y: pixel.y + previousY))
            pixels.insert(Pixel(x: pixel.x + newX, y: pixel.y + newY))
        }

        self.previousX = newX
        self.previousY = newY

        game.render(pixels: pixels)
    }

}

