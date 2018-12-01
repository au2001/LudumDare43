//
//  Controls.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

let LEFT_KEY: UInt16 = 123
let RIGHT_KEY: UInt16 = 124
let UP_KEY: UInt16 = 126
let DOWN_KEY: UInt16 = 125
let SPEED = 30.0
let SQRT_2 = sqrt(2)

class Controls {

    func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        return try body()
    }

    func tick(game: Game, delta: TimeInterval) {
        if delta <= 0 {
            return
        }

        var moveX = 0.0, moveY = 0.0

        if game.keysDown.contains(LEFT_KEY) {
            moveX -= 1
        }
        if game.keysDown.contains(RIGHT_KEY) {
            moveX += 1
        }
        if game.keysDown.contains(UP_KEY) {
            moveY -= 1
        }
        if game.keysDown.contains(DOWN_KEY) {
            moveY += 1
        }

        if moveX == 0 && moveY == 0 {
            return
        }

        if moveX != 0 && moveY != 0 {
            moveX /= SQRT_2
            moveY /= SQRT_2
        }

        synchronized(game.player) {
            let previouxX = game.player.x, previousY = game.player.y
            game.player.x += moveX * SPEED * delta
            game.player.y += moveY * SPEED * delta

            for _ in game.player.getCollisions(game: game) {
                game.player.x = previouxX
                game.player.y = previousY
                return
            }

            game.player.update(game: game)
        }
    }

}

