//
//  Sprite.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Sprite: Equatable {

    static func == (lhs: Sprite, rhs: Sprite) -> Bool {
        return lhs.name == rhs.name
    }

    static let EMPTY: Sprite = Sprite(name: "empty", pixels: [], anchorX: 0, anchorY: 0)

    let name: String
    let pixels: [[CGColor]]
    let anchorX, anchorY: Int
    let width, height: Int
    let minX, minY, maxX, maxY: Int
    var hitbox0: Set<Pixel> = [], hitbox05: Set<Pixel> = []

    init(name: String, pixels: [[CGColor]], anchorX: Int, anchorY: Int) {
        self.name = name
        self.pixels = pixels
        self.anchorX = anchorX
        self.anchorY = anchorY

        self.width = pixels.first?.count ?? 0
        self.height = pixels.count

        self.minX = -self.anchorX
        self.minY = -self.anchorY

        self.maxX = self.width > 0 ? self.width - self.anchorX - 1 : self.minX
        self.maxY = self.height > 0 ? self.height - self.anchorY - 1 : self.minY

        for x in self.minX...self.maxX {
            for y in self.minY...self.maxY {
                let color = self.getColor(x: x, y: y)
                if color.alpha > 0.5 {
                    let pixel = Pixel(x: x, y: y)
                    self.hitbox0.insert(pixel)
                    self.hitbox05.insert(pixel)
                } else if color.alpha > 0 {
                    let pixel = Pixel(x: x, y: y)
                    self.hitbox0.insert(pixel)
                }
            }
        }
    }

    func getWidth() -> Int {
        return self.width
    }

    func getHeight() -> Int {
        return self.height
    }

    func getMinX() -> Int {
        return self.minX
    }

    func getMinY() -> Int {
        return self.minY
    }

    func getMaxX() -> Int {
        return self.maxX
    }

    func getMaxY() -> Int {
        return self.maxY
    }

    func getColor(x: Int, y: Int) -> CGColor {
        let x = x + self.anchorX, y = y + self.anchorY

        if x < 0 || x >= self.getWidth() || y < 0 || y >= self.getHeight() {
            return .clear
        }

        return self.pixels[y][x]
    }

    func getViewBox() -> Set<Pixel> {
        return self.hitbox0
    }

    func isHitBox(x: Int, y: Int, threshold: Double = 0.5) -> Bool {
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

    func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        if threshold == 0.5 {
            return self.hitbox05
        } else if threshold == 0 {
            return self.hitbox0
        } else {
            var hitbox: Set<Pixel> = []

            for x in self.getMinX()...self.getMaxX() {
                for y in self.getMinY()...self.getMaxY() {
                    if self.isHitBox(x: x, y: y, threshold: threshold) {
                        hitbox.insert(Pixel(x: x, y: y))
                    }
                }
            }

            return hitbox
        }
    }

}

