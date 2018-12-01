//
//  SpriteLoader.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Foundation

extension Level {

    static func generate(width: Int = 360 + (360 - 14) * 9, height: Int = 225 + (225 - 18) * 9) -> Level? {
        guard let background = Sprite.load(name: "background"), let character = Sprite.load(name: "character") else {
            return nil
        }

        let entities: [Entity] = []

        return Level(background: background, character: character, spawnX: Double(width) / 2, spawnY: Double(height) / 2, width: width, height: height, entities: entities)
    }

}

