//
//  Game.swift
//  Walrus
//
//  Created by Aurélien on 28/11/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

let FPS = 60

class Game {

    let contentView: ContentView

    var timer: Timer?
    var keysDown: [UInt16] = []
    let controls = Controls()
    var lastTick: TimeInterval = 0
    var rendering = false
    var entities: [Entity] = []

    init(contentView: ContentView) {
        self.contentView = contentView
    }

    func start() {
        if self.timer == nil {
            self.lastTick = Date().timeIntervalSinceReferenceDate
            self.timer = Timer.scheduledTimer(timeInterval: 1 / TimeInterval(FPS), target: self, selector: #selector(Game.tick), userInfo: nil, repeats: true)
        }
    }

    func stop() {
        if self.timer == nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func keyPress(event: NSEvent) {

    }

    func keyDown(event: NSEvent) {
        self.keysDown.append(event.keyCode)
    }

    func keyUp(event: NSEvent) {
        if let index = self.keysDown.index(of: event.keyCode) {
            self.keysDown.remove(at: index)
        }
    }

    @objc func tick() {
        let now = Date().timeIntervalSinceReferenceDate
        let delta = now - self.lastTick

        self.controls.tick(game: self, delta: delta)
        self.render()

        self.lastTick = now
    }

    func render() {
        if self.rendering {
            return // Skip frame
        }

        self.rendering = true

        for entity in self.entities {
            self.contentView.paintSprite(x: entity.x, y: entity.y, sprite: entity.sprite)
        }

        self.rendering = false
    }

}

