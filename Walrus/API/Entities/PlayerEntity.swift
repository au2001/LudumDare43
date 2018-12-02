//
//  PlayerEntity.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class PlayerEntity: Entity {

    let controls = Controls()

    override func tick(game: Game, delta: TimeInterval) {
        if delta <= 0 {
            return
        }

        self.controls.tick(game: game, delta: delta)

        super.tick(game: game, delta: delta)
    }

}

