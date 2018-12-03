//
//  TempleEntity.swift
//  Walrus
//
//  Created by Aurélien on 02/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class TempleEntity: Entity {

    let minSacrificeDuration: Double = 10
    let maxSacrificeDuration: Double = 30

    var sacrificing = false
    var nextAvailability: Double = 0

    override func tick(game: Game, delta: TimeInterval) {
        if delta <= 0 || !self.sacrificing {
            return
        }

        if self.nextAvailability > self.maxSacrificeDuration {
            self.nextAvailability = Double.random(in: self.minSacrificeDuration...self.maxSacrificeDuration)
        }

        self.nextAvailability -= delta

        if self.nextAvailability > 0 {
            return
        }

        self.setSacrificing(sacrificing: false, inGame: game)
    }

    func setSacrificing(sacrificing: Bool, inGame game: Game) {
        if sacrificing == self.sacrificing {
            return
        }

        if sacrificing {
            let now = Date().timeIntervalSince1970
            self.nextAvailability = now + Double.random(in: self.minSacrificeDuration...self.maxSacrificeDuration)

            if (self.sprite as! StatusSprite).status != "sacrificing" {
                let newSprite = (self.sprite as! StatusSprite).copy() as! StatusSprite
                newSprite.status = "sacrificing"

                self.update(game: game, toSprite: newSprite)
            }
        } else {
            self.nextAvailability = 0

            if (self.sprite as! StatusSprite).status == "sacrificing" {
                let newSprite = (self.sprite as! StatusSprite).copy() as! StatusSprite
                newSprite.status = "available"

                self.update(game: game, toSprite: newSprite)
            }
        }

        self.sacrificing = sacrificing
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let temple = TempleEntity(sprite: self.sprite, x: self.x, y: self.y)
        temple.sacrificing = self.sacrificing
        temple.nextAvailability = self.nextAvailability
        return temple
    }

}

