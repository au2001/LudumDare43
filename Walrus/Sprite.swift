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
        return -anchorX
    }

    func getMinY() -> Int {
        return -anchorY
    }

    func getMaxX() -> Int {
        return self.getWidth() - 1 - self.anchorX
    }

    func getMaxY() -> Int {
        return self.getHeight() - 1 - anchorY
    }

    func getColor(x: Int, y: Int) -> CGColor {
        let x = x + anchorX, y = y + anchorY

        if x < 0 || x >= self.getWidth() || y < 0 || y >= self.getHeight() {
            return .clear
        }

        return self.pixels[y][x]
    }

    func isHitBox(x: Int, y: Int) -> Bool {
        return self.getColor(x: x, y: y).alpha >= 0.5
    }

}

