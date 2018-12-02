//
//  TempleEntity.swift
//  Walrus
//
//  Created by Aurélien on 02/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class TempleEntity: Entity {

    var burning = false

    // TODO

    func setBurning(burning: Bool, inGame: Game) {
        // TODO
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let bush = TempleEntity(sprite: self.sprite, x: self.x, y: self.y)
        // TODO
        return bush
    }

}

