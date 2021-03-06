//
//  CombinedSprite.swift
//  TheAlpacaSacrifice
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 TheAlpacaSacrifice. All rights reserved.
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
            if sprite as? TilingSprite == nil {
                combinedMinX = min(sprite.getMinX() + position.x, combinedMinX)
                combinedMinY = min(sprite.getMinY() + position.y, combinedMinY)
                combinedMaxX = max(sprite.getMaxX() + position.x, combinedMaxX)
                combinedMaxY = max(sprite.getMaxY() + position.y, combinedMaxY)
            }

            for pixel in sprite.getHitBox(threshold: 0) {
                self.combinedHitbox0.insert(Pixel(x: pixel.x + position.x, y: pixel.y + position.y))
            }

            for pixel in sprite.getHitBox(threshold: 0.5) {
                self.combinedHitbox05.insert(Pixel(x: pixel.x + position.x, y: pixel.y + position.y))
            }
        }

        if combinedMaxX < combinedMinX {
            self.combinedWidth = sprites.isEmpty ? 0 : Int.max
            self.combinedMinX = sprites.isEmpty ? 0 : Int.min
            self.combinedMaxX = sprites.isEmpty ? 0 : Int.max
        } else {
            self.combinedWidth = combinedMaxX - combinedMinX
            self.combinedMinX = combinedMinX
            self.combinedMaxX = combinedMaxX
        }

        if combinedMaxY < combinedMinY {
            self.combinedHeight = sprites.isEmpty ? 0 : Int.max
            self.combinedMinY = sprites.isEmpty ? 0 : Int.min
            self.combinedMaxY = sprites.isEmpty ? 0 : Int.max
        } else {
            self.combinedHeight = combinedMaxY - combinedMinY
            self.combinedMinY = combinedMinY
            self.combinedMaxY = combinedMaxY
        }

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

    override func getViewBox() -> Set<Pixel> {
        return self.hitbox0
    }

    override func isHitBox(x: Int, y: Int, threshold: Double) -> Bool {
        if threshold == 0.5 {
            return self.hitbox05.contains(Pixel(x: x, y: y))
        } else if threshold == 0 {
            return self.hitbox0.contains(Pixel(x: x, y: y))
        } else {
            if self.getColor(x: x, y: y).alpha > CGFloat(threshold) {
                return true
            }
            return false
        }
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

