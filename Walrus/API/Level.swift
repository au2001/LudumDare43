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

    init(background: Sprite, character: Sprite, entities: [Entity]) {
        self.background = background
        self.character = character
        self.entities = entities
    }

}

