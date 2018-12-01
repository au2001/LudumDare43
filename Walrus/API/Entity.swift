//
//  Entity.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Entity: Equatable {

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
    }

    static var CURRENT_ID = -1
    static var NEXT_ID: Int {
        Entity.CURRENT_ID += 1
        return Entity.CURRENT_ID
    }

    let id: Int
    let sprite: Sprite
    var x, y: Double
    var previousX, previousY: Int

    init(sprite: Sprite, x: Double, y: Double) {
        self.id = Entity.NEXT_ID
        self.sprite = sprite
        self.x = x
        self.y = y
        self.previousX = Int(x)
        self.previousY = Int(y)
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
        if self == entity {
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

    func collides(with entity: Entity, game: Game, threshold: Double = 0.5) -> Bool {
        if self.x + Double(self.sprite.getMaxX() + 1) < entity.x + Double(entity.sprite.getMinX()) || self.x + Double(self.sprite.getMinX()) > entity.x + Double(entity.sprite.getMaxX() + 1) {
            return false
        }
        if self.y + Double(self.sprite.getMaxY() + 1) < entity.y + Double(entity.sprite.getMinY()) || self.y + Double(self.sprite.getMinY()) > entity.y + Double(entity.sprite.getMaxY() + 1) {
            return false
        }

        if !self.canCollide(with: entity, game: game) || !entity.canCollide(with: self, game: game) {
            return false
        }

        if self.sprite.getWidth() * self.sprite.getHeight() <= entity.sprite.getWidth() * entity.sprite.getHeight() {
            for pixel in self.sprite.getHitBox(threshold: threshold) {
                if entity.sprite.getColor(x: Int(self.x) - Int(entity.x) + pixel.x, y: Int(self.y) - Int(entity.y) + pixel.y).alpha > CGFloat(threshold) {
                    return true
                }
            }
        } else {
            for pixel in entity.sprite.getHitBox(threshold: threshold) {
                if self.sprite.getColor(x: Int(entity.x) - Int(self.x) + pixel.x, y: Int(entity.y) - Int(self.y) + pixel.y).alpha > CGFloat(threshold) {
                    return true
                }
            }
        }

        return false
    }

    func getCollisions(game: Game, threshold: Double = 0.5) -> [Entity] {
        var collisions: [Entity] = []

        for entity in game.entities + [game.player] {
            if self.collides(with: entity, game: game, threshold: threshold) {
                collisions.append(entity)
            }
        }

        return collisions
    }

}

