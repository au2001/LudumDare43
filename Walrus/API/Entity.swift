//
//  Entity.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

var CURRENT_ID = -1
var NEXT_ID: Int {
    CURRENT_ID += 1
    return CURRENT_ID
}

class Entity {

    let id: Int
    let sprite: Sprite
    var x = 0.0, y = 0.0
    var previousX = 0, previousY = 0

    init(sprite: Sprite) {
        self.id = NEXT_ID
        self.sprite = sprite
    }

    func update(game: Game, collide: Bool = true) {
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

    func canCollide(with entity: Entity, game: Game) -> Bool {
        if self.id == entity.id {
            return false
        }

        return true
    }

    func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        var hitbox: Set<Pixel> = []

        for pixel in self.sprite.getHitBox(threshold: threshold) {
            hitbox.insert(Pixel(x: Int(self.x) + pixel.x, y: Int(self.y) + pixel.y))
        }

        return hitbox
    }

    func handleCollisions(game: Game, callback: ((Entity) -> Bool), threshold: Double = 0.5) {
        for entity in game.entities + [game.player] {
            if !self.canCollide(with: entity, game: game) || !entity.canCollide(with: self, game: game) {
                continue
            }

            if self.getHitBox(threshold: threshold).isDisjoint(with: entity.getHitBox(threshold: threshold)) {
                continue
            }

            if !callback(entity) {
                break
            }
        }
    }

}

