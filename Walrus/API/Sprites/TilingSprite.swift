//
//  TilingSprite.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class TilingSprite: Sprite {

    let tile: Sprite

    convenience init(tile: Sprite) {
        self.init(name: "TilingSprite@" + tile.name, tile: tile)
    }

    init(name: String, tile: Sprite) {
        self.tile = tile

        super.init(name: name, pixels: [], anchorX: tile.anchorX, anchorY: tile.anchorY)
    }

    override func getWidth() -> Int {
        return Int.max
    }

    override func getHeight() -> Int {
        return Int.max
    }

    override func getMinX() -> Int {
        return Int.min
    }

    override func getMinY() -> Int {
        return Int.min
    }

    override func getMaxX() -> Int {
        return Int.max
    }

    override func getMaxY() -> Int {
        return Int.max
    }

    override func getColor(x: Int, y: Int) -> CGColor {
        let x = x % tile.getWidth()
        let y = y % tile.getHeight()
        return self.tile.getColor(x: x, y: y)
    }

    override func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        return []
    }

}

