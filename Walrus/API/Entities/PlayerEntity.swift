//
//  PlayerEntity.swift
//  Walrus
//
//  Created by Aurélien on 02/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class PlayerEntity: Entity {

    let controls = Controls()
    var carrying = false

    override func tick(game: Game, delta: TimeInterval) {
        if delta <= 0 {
            return
        }

        self.controls.tick(game: game, delta: delta)
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        return PlayerEntity(sprite: self.sprite, x: self.x, y: self.y)
    }

}

