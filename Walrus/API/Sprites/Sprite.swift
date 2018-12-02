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

    let name: String
    let pixels: [[CGColor]]
    let anchorX, anchorY: Int

    init(name: String, pixels: [[CGColor]], anchorX: Int, anchorY: Int) {
        self.name = name
        self.pixels = pixels
        self.anchorX = anchorX
        self.anchorY = anchorY
    }

    func getWidth() -> Int {
        return pixels.first?.count ?? 0
    }

    func getHeight() -> Int {
        return pixels.count
    }

    func getMinX() -> Int {
        return -self.anchorX
    }

    func getMinY() -> Int {
        return -self.anchorY
    }

    func getMaxX() -> Int {
        let width = self.getWidth()
        if width <= 0 {
            return self.getMinX()
        }
        return width - self.anchorX - 1
    }

    func getMaxY() -> Int {
        let height = self.getHeight()
        if height <= 0 {
            return self.getMinY()
        }
        return height - self.anchorY - 1
    }

    func getColor(x: Int, y: Int) -> CGColor {
        let x = x + self.anchorX, y = y + self.anchorY

        if x < 0 || x >= self.getWidth() || y < 0 || y >= self.getHeight() {
            return .clear
        }

        return self.pixels[y][x]
    }

    func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        var hitbox: Set<Pixel> = []

        for x in self.getMinX()...self.getMaxX() {
            for y in self.getMinY()...self.getMaxY() {
                if self.getColor(x: x, y: y).alpha > CGFloat(threshold) {
                    hitbox.insert(Pixel(x: x, y: y))
                }
            }
        }

        return hitbox
    }

}

