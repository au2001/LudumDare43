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

    var direction = "s"

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
            if (game.player.sprite as! StatusSprite).getStatus() != "idle_" + self.direction {
                let newSprite = (game.player.sprite as! StatusSprite).copy() as! StatusSprite
                newSprite.setStatus(to: "idle_" + self.direction)

                for _ in game.player.getCollisions(game: game, withSprite: newSprite) {
                    return
                }

                game.player.update(game: game, toSprite: newSprite)
            }
            return
        }

        if moveX != 0 && moveY != 0 {
            moveX /= SQRT_2
            moveY /= SQRT_2

            let rx = (game.player.x - game.player.x.rounded(.down)).truncatingRemainder(dividingBy: 1)
            let ry = (game.player.y - game.player.y.rounded(.down)).truncatingRemainder(dividingBy: 1)

            let nx = rx + moveX * SPEED * delta
            let ny = ry + moveY * SPEED * delta

            if (nx < 0 || nx > 1) != (ny < 0 || ny > 1) {
                if (nx < 0 || nx > 1) && !(ny < 0 || ny > 1) {
                    if (moveX > 0) == (moveY > 0) {
                        // rx + moveX * SPEED * delta = ry + moveY * SPEED * delta
                        // moveX * SPEED * delta = ry - rx + moveY * SPEED * delta
                        // moveX = ry - rx + moveY
                        moveX = ry - rx + moveY
                    } else {
                        // rx + moveX * SPEED * delta = ry - moveY * SPEED * delta
                        // moveX * SPEED * delta = ry - rx- moveY * SPEED * delta
                        // moveX = ry - rx - moveY
                        moveX = ry - rx - moveY
                    }
                } else if (ny < 0 || ny > 1) && !(nx < 0 || nx > 1) {
                    if (moveX > 0) == (moveY > 0) {
                        moveY = rx - ry + moveX
                    } else {
                        moveY = rx - ry - moveX
                    }
                }
            }
        }

        synchronized(game.player) {
            let previouxX = game.player.x, previousY = game.player.y
            game.player.x += moveX * SPEED * delta
            game.player.y += moveY * SPEED * delta

            var newDirection = self.direction

            if moveX > 0 {
                if moveY > 0 {
                    newDirection = "se"
                } else if moveY < 0 {
                    newDirection = "ne"
                } else {
                    newDirection = "e"
                }
            } else if moveX < 0 {
                if moveY > 0 {
                    newDirection = "sw"
                } else if moveY < 0 {
                    newDirection = "nw"
                } else {
                    newDirection = "w"
                }
            } else {
                if moveY > 0 {
                    newDirection = "s"
                } else if moveY < 0 {
                    newDirection = "n"
                } else {
                    newDirection = "s"
                }
            }

            if newDirection != self.direction {
                let newSprite = (game.player.sprite as! StatusSprite).copy() as! StatusSprite
                newSprite.setStatus(to: "walking_" + newDirection)

                for _ in game.player.getCollisions(game: game, withSprite: newSprite) {
                    game.player.x = previouxX
                    game.player.y = previousY
                    return
                }

                self.direction = newDirection
                game.player.update(game: game, toSprite: newSprite)
            } else {
                for _ in game.player.getCollisions(game: game) {
                    game.player.x = previouxX
                    game.player.y = previousY
                    return
                }

                game.player.update(game: game)
            }
        }
    }

}

