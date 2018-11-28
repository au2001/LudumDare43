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
    var pendingPaint: [CGRect] = []
    var painting = false
    var entities: [Entity] = []
    var cameraOffsetX = 0, cameraOffsetY = 0
    let background: Sprite

    let player: Entity

    init(contentView: ContentView) {
        self.contentView = contentView
        self.background = Sprite.load(name: "background")!
        self.player = Entity(sprite: Sprite.load(name: "character")!)
        self.player.x = Double(self.contentView.width) / 2
        self.player.y = Double(self.contentView.height) / 2

        self.render()
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
        self.paint()

        self.lastTick = now
    }

    func render() {
        self.render(rect: CGRect(x: 0, y: 0, width: self.contentView.width, height: self.contentView.height))
    }

    func render(rect: CGRect) {
        if rect.width == 0 || rect.height == 0 {
            return
        }

        self.pendingPaint.append(rect)
    }

    func paint() {
        if self.pendingPaint.isEmpty {
            return
        }

        if self.painting {
            print("Skipped a frame.")
            return
        }

        self.painting = true

        DispatchQueue.main.async {
            // TODO: Only refresh pending paint rectangles
            self.pendingPaint.removeAll()

            self.contentView.paintSprite(x: -self.cameraOffsetX, y: -self.cameraOffsetY, sprite: self.background)
            for entity in self.entities {
                if Int(entity.x) + entity.sprite.getMaxX() - self.cameraOffsetX < 0 || Int(entity.x) + entity.sprite.getMinX() - self.cameraOffsetX > self.contentView.width {
                    continue
                }
                if Int(entity.y) + entity.sprite.getMaxY() - self.cameraOffsetY < 0 || Int(entity.y) + entity.sprite.getMinY() - self.cameraOffsetY > self.contentView.height {
                    continue
                }

                self.contentView.paintSprite(x: Int(entity.x) - self.cameraOffsetX, y: Int(entity.y) - self.cameraOffsetY, sprite: entity.sprite)
            }
            self.contentView.paintSprite(x: Int(self.player.x) - self.cameraOffsetX, y: Int(self.player.y) - self.cameraOffsetY, sprite: self.player.sprite)

            self.painting = false
        }
    }

}

