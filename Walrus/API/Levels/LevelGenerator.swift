//
//  SpriteLoader.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Foundation

extension Level {

    static func generate() -> Level? {
        guard let background = Sprite.load(name: "background"), let character = Sprite.load(name: "character") else {
            return nil
        }

        let entities: [Entity] = []

        return Level(background: background, character: character, entities: entities)
    }

}

