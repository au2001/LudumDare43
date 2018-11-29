//
//  Sprite.swift
//  Walrus
//
//  Created by Aurélien on 28/11/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Sprite {

    let pixels: [[CGColor]]
    let anchorX, anchorY: Int

    init(pixels: [[CGColor]], anchorX: Int, anchorY: Int) {
        self.pixels = pixels
        self.anchorX = anchorX
        self.anchorY = anchorY
    }

    func getHeight() -> Int {
        return pixels.count
    }

    func getWidth() -> Int {
        return pixels.first?.count ?? 0
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
        let x = x + anchorX, y = y + anchorY

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

