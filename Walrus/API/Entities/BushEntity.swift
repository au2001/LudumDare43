//
//  BushEntity.swift
//  Walrus
//
//  Created by Aurélien on 02/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class BushEntity: Entity {

    let minRespawnDelay: Double = 30
    let maxRespawnDelay: Double = 90

    var alpaca = false
    var nextSpawn: Double = Double.infinity

    override func tick(game: Game, delta: TimeInterval) {
        if delta <= 0 || self.alpaca {
            return
        }

        if self.nextSpawn > self.maxRespawnDelay {
            self.nextSpawn = Double.random(in: self.minRespawnDelay...self.maxRespawnDelay)
        }

        self.nextSpawn -= delta

        if self.nextSpawn > 0 {
            return
        }

        self.setAlpaca(present: true, inGame: game)
    }

    func setAlpaca(present alpaca: Bool, inGame game: Game) {
        if alpaca == self.alpaca {
            return
        }

        if alpaca {
            self.nextSpawn = 0

            if (self.sprite as! StatusSprite).status != "alpaca" {
                let newSprite = (self.sprite as! StatusSprite).copy() as! StatusSprite
                newSprite.status = "alpaca"

                self.update(game: game, toSprite: newSprite)
            }
        } else {
            let now = Date().timeIntervalSince1970
            self.nextSpawn = now + Double.random(in: self.minRespawnDelay...self.maxRespawnDelay)

            if (self.sprite as! StatusSprite).status == "alpaca" {
                let newSprite = (self.sprite as! StatusSprite).copy() as! StatusSprite
                newSprite.status = "empty"

                self.update(game: game, toSprite: newSprite)
            }
        }

        self.alpaca = alpaca
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let bush = BushEntity(sprite: self.sprite, x: self.x, y: self.y)
        bush.alpaca = self.alpaca
        bush.nextSpawn = self.nextSpawn
        return bush
    }

}

