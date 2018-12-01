//
//  CombinedSprite.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class CombinedSprite: Sprite {

    static var CURRENT_ID = -1
    static var NEXT_ID: String {
        CombinedSprite.CURRENT_ID += 1
        return String(CombinedSprite.CURRENT_ID, radix: 16, uppercase: false)
    }

    var sprites: [(sprite: Sprite, position: Pixel)]

    convenience init(sprites: [(sprite: Sprite, position: Pixel)]) {
        self.init(name: "CombinedSprite@" + CombinedSprite.NEXT_ID, sprites: sprites)
    }

    init(name: String, sprites: [(sprite: Sprite, position: Pixel)]) {
        self.sprites = sprites

        super.init(name: name, pixels: [], anchorX: 0, anchorY: 0)
    }

    func add(sprite: Sprite, at position: Pixel) {
        sprites.append((sprite: sprite, position: position))
    }

    func remove(sprite: Sprite, from position: Pixel) {
        self.sprites.removeAll { (entry) -> Bool in
            let (otherSprite, otherPosition) = entry
            return otherSprite == sprite && otherPosition == position
        }
    }

    override func getWidth() -> Int {
        var minX = 0, maxX = 0
        for (sprite, position) in self.sprites {
            minX = min(sprite.getMinX() + position.x, minX)
            maxX = max(sprite.getMaxX() + position.x, maxX)
        }
        return maxX - minX
    }

    override func getHeight() -> Int {
        var minY = 0, maxY = 0
        for (sprite, position) in self.sprites {
            minY = min(sprite.getMinY() + position.y, minY)
            maxY = max(sprite.getMaxY() + position.y, maxY)
        }
        return maxY - minY
    }

    override func getMinX() -> Int {
        var minX = 0
        for (sprite, position) in self.sprites {
            minX = min(sprite.getMinX() + position.x, minX)
        }
        return minX
    }

    override func getMinY() -> Int {
        var minY = 0
        for (sprite, position) in self.sprites {
            minY = min(sprite.getMinY() + position.y, minY)
        }
        return minY
    }

    override func getMaxX() -> Int {
        var maxX = 0
        for (sprite, position) in self.sprites {
            maxX = max(sprite.getMaxX() + position.x, maxX)
        }
        return maxX
    }

    override func getMaxY() -> Int {
        var maxY = 0
        for (sprite, position) in self.sprites {
            maxY = max(sprite.getMaxY() + position.y, maxY)
        }
        return maxY
    }

    override func getColor(x: Int, y: Int) -> CGColor {
        var color = CGColor.clear

        for (sprite, position) in self.sprites {
            color = ContentView.blend(color: sprite.getColor(x: x - position.x, y: y - position.y), above: color)
        }

        return color
    }

    override func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        var hitbox: Set<Pixel> = []

        for (sprite, position) in self.sprites {
            for pixel in sprite.getHitBox(threshold: threshold) {
                hitbox.insert(Pixel(x: position.x + pixel.x, y: position.y + pixel.y))
            }
        }

        return hitbox
    }

}

