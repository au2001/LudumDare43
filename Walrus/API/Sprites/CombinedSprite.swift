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

    let sprites: [(sprite: Sprite, position: Pixel)]
    let combinedWidth, combinedHeight: Int
    let combinedMinX, combinedMinY, combinedMaxX, combinedMaxY: Int
    var combinedHitbox0: Set<Pixel> = [], combinedHitbox05: Set<Pixel> = []

    convenience init(sprites: [(sprite: Sprite, position: Pixel)]) {
        self.init(name: "CombinedSprite@" + CombinedSprite.NEXT_ID, sprites: sprites)
    }

    init(name: String, sprites: [(sprite: Sprite, position: Pixel)]) {
        self.sprites = sprites

        var combinedMinX = Int.max, combinedMinY = Int.max, combinedMaxX = 0, combinedMaxY = 0
        for (sprite, position) in self.sprites {
            combinedMinX = min(sprite.getMinX() + position.x, combinedMinX)
            combinedMinY = min(sprite.getMinY() + position.y, combinedMinY)
            combinedMaxX = max(sprite.getMaxX() + position.x, combinedMaxX)
            combinedMaxY = max(sprite.getMaxY() + position.y, combinedMaxY)

            for pixel in sprite.getHitBox(threshold: 0) {
                self.combinedHitbox0.insert(Pixel(x: pixel.x + position.x, y: pixel.y + position.y))
            }

            for pixel in sprite.getHitBox(threshold: 0.5) {
                self.combinedHitbox05.insert(Pixel(x: pixel.x + position.x, y: pixel.y + position.y))
            }
        }
        self.combinedWidth = combinedMaxX - combinedMinX
        self.combinedHeight = combinedMaxY - combinedMinY
        self.combinedMinX = combinedMinX
        self.combinedMinY = combinedMinY
        self.combinedMaxX = combinedMaxX
        self.combinedMaxY = combinedMaxY

        super.init(name: name, pixels: [], anchorX: 0, anchorY: 0)
    }

//    func add(sprite: Sprite, at position: Pixel) {
//        sprites.append((sprite: sprite, position: position))
//    }
//
//    func remove(sprite: Sprite, from position: Pixel) {
//        self.sprites.removeAll { (entry) -> Bool in
//            let (otherSprite, otherPosition) = entry
//            return otherSprite == sprite && otherPosition == position
//        }
//    }

    override func getWidth() -> Int {
        return self.combinedWidth
    }

    override func getHeight() -> Int {
        return self.combinedHeight
    }

    override func getMinX() -> Int {
        return self.combinedMinX
    }

    override func getMinY() -> Int {
        return self.combinedMinY
    }

    override func getMaxX() -> Int {
        return self.combinedMaxX
    }

    override func getMaxY() -> Int {
        return self.combinedMaxY
    }

    override func getColor(x: Int, y: Int) -> CGColor {
        var color = CGColor.clear

        for (sprite, position) in self.sprites {
            color = Utils.blend(color: sprite.getColor(x: x - position.x, y: y - position.y), above: color)
        }

        return color
    }

    override func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        if threshold == 0.5 {
            return self.hitbox05
        } else if threshold == 0 {
            return self.hitbox0
        } else {
            var hitbox: Set<Pixel> = []

            for (sprite, position) in self.sprites {
                for pixel in sprite.getHitBox(threshold: threshold) {
                    hitbox.insert(Pixel(x: position.x + pixel.x, y: position.y + pixel.y))
                }
            }

            return hitbox
        }
    }

}

