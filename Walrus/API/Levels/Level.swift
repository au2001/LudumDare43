//
//  Level.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Level {

    let background: Sprite
    let character: Sprite
    let entities: [Entity]
    let spawnX, spawnY: Double
    let width, height: Int

    init(background: Sprite, character: Sprite, spawnX: Double, spawnY: Double, width: Int, height: Int, entities: [Entity]) {
        self.background = background
        self.character = character
        self.spawnX = spawnX
        self.spawnY = spawnY
        self.width = width
        self.height = height
        self.entities = entities
    }

}

