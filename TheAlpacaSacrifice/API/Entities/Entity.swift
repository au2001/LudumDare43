//
//  Entity.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Entity: Equatable, NSCopying {

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
    }

    static var CURRENT_ID = -1
    static var NEXT_ID: Int {
        Entity.CURRENT_ID += 1
        return Entity.CURRENT_ID
    }

    let id: Int
    var sprite: Sprite
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

    func tick(game: Game, delta: TimeInterval) {}

    func update(game: Game, toSprite sprite: Sprite? = nil) {
        let newX = Int(self.x), newY = Int(self.y)

        if sprite == nil && newX == self.previousX && newY == self.previousY {
            return
        }

        var pixels: Set<Pixel> = []

        for pixel in self.sprite.getViewBox() {
            pixels.insert(Pixel(x: pixel.x + previousX, y: pixel.y + previousY))

            if sprite == nil && (newX != self.previousX || newY != self.previousY) {
                pixels.insert(Pixel(x: pixel.x + newX, y: pixel.y + newY))
            }
        }

        if let sprite = sprite {
            for pixel in sprite.getViewBox() {
                pixels.insert(Pixel(x: pixel.x + newX, y: pixel.y + newY))
            }
            self.sprite = sprite
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

    func collides(with entity: Entity, game: Game, withSprite sprite: Sprite? = nil, threshold: Double = 0.5) -> Bool {
        let sprite = sprite ?? self.sprite

        if self.x + Double(sprite.getMaxX() + 1) < entity.x + Double(entity.sprite.getMinX()) || self.x + Double(sprite.getMinX()) > entity.x + Double(entity.sprite.getMaxX() + 1) {
            return false
        }
        if self.y + Double(sprite.getMaxY() + 1) < entity.y + Double(entity.sprite.getMinY()) || self.y + Double(sprite.getMinY()) > entity.y + Double(entity.sprite.getMaxY() + 1) {
            return false
        }

        if !self.canCollide(with: entity, game: game) || !entity.canCollide(with: self, game: game) {
            return false
        }

        if sprite.getWidth() * sprite.getHeight() <= entity.sprite.getWidth() * entity.sprite.getHeight() {
            for pixel in sprite.getHitBox(threshold: threshold) {
                if entity.sprite.isHitBox(x: Int(self.x) - Int(entity.x) + pixel.x, y: Int(self.y) - Int(entity.y) + pixel.y, threshold: threshold) {
                    return true
                }
            }
        } else {
            for pixel in entity.sprite.getHitBox(threshold: threshold) {
                if sprite.isHitBox(x: Int(entity.x) - Int(self.x) + pixel.x, y: Int(entity.y) - Int(self.y) + pixel.y, threshold: threshold) {
                    return true
                }
            }
        }

        return false
    }

    func getCollisions(game: Game, withSprite sprite: Sprite? = nil, threshold: Double = 0.5) -> [Entity] {
        var collisions: [Entity] = []

        for entity in game.entities + [game.player] {
            if self.collides(with: entity, game: game, withSprite: sprite, threshold: threshold) {
                collisions.append(entity)
            }
        }

        return collisions
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return Entity(sprite: self.sprite, x: self.x, y: self.y)
    }

}

