//
//  Game.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Game {

    let level: Level
    let contentView: ContentView

    var timer: Timer?
    var displayLink: CVDisplayLink?
    let paintThread = DispatchQueue(label: "PaintThreadQueue")

    var keysDown: [UInt16] = []
    var lastTick: TimeInterval = -1

    var pendingPaint: Set<Pixel> = []
    var painting = false

    var entities: [Entity] = []
    var cameraOffsetX = 0, cameraOffsetY = 0

    let player: PlayerEntity

    init(level: Level, contentView: ContentView) {
        self.level = level
        self.contentView = contentView

        for entity in level.entities {
            self.entities.append(entity.copy() as! Entity)
        }

        self.player = PlayerEntity(sprite: level.character, x: level.spawnX, y: level.spawnY)

        self.tick()
        self.render()
    }

    func start() {
        if self.displayLink == nil {
            self.lastTick = Date().timeIntervalSince1970
            CVDisplayLinkCreateWithActiveCGDisplays(&self.displayLink)

            if let displayLink = self.displayLink {
                let displayLinkOutputCallback: CVDisplayLinkOutputCallback = { (displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
                    let game = unsafeBitCast(displayLinkContext, to: Game.self)
                    game.paint()
                    return kCVReturnSuccess
                }

                CVDisplayLinkSetOutputCallback(displayLink, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
                CVDisplayLinkStart(displayLink)
            }
        }

        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true, block: { (timer) in
                self.tick()
            })
        }
    }

    func stop() {
        if let displayLink = self.displayLink {
            CVDisplayLinkStop(displayLink)
        }
        self.displayLink = nil
    }

    func keyPress(event: NSEvent) {
        self.player.controls.keyPress(game: self, key: event.keyCode)
    }

    func keyDown(event: NSEvent) {
        if self.keysDown.contains(event.keyCode) {
            return
        }

        self.tick()
        self.keysDown.append(event.keyCode)
    }

    func keyUp(event: NSEvent) {
        if let index = self.keysDown.index(of: event.keyCode) {
            self.tick()
            self.keysDown.remove(at: index)
        }
    }

    func tick() {
        if self.lastTick >= 0 {
            let now = Date().timeIntervalSince1970
            let delta = now - self.lastTick
            self.lastTick = now

            self.player.tick(game: self, delta: delta)
            for entity in self.entities {
                entity.tick(game: self, delta: delta)
            }
        }

        var fullRender = false

        while Int(self.player.x) + self.player.sprite.getMinX() < self.cameraOffsetX {
            if self.cameraOffsetX <= 0 {
                break
            }

            self.cameraOffsetX -= self.contentView.width - self.player.sprite.getWidth() + 1
            fullRender = true

            if self.cameraOffsetX <= 0 {
                self.cameraOffsetX = 0
                break
            }
        }

        while Int(self.player.x) + self.player.sprite.getMaxX() >= self.cameraOffsetX + self.contentView.width {
            if self.cameraOffsetX >= self.level.width - self.contentView.width {
                break
            }

            self.cameraOffsetX += self.contentView.width - self.player.sprite.getWidth() + 1
            fullRender = true

            if self.cameraOffsetX >= self.level.width - self.contentView.width {
                self.cameraOffsetX = self.level.width - self.contentView.width
                break
            }
        }

        while Int(self.player.y) + self.player.sprite.getMinY() < self.cameraOffsetY {
            if self.cameraOffsetY <= 0 {
                break
            }

            self.cameraOffsetY -= self.contentView.height - self.player.sprite.getHeight() + 1
            fullRender = true

            if self.cameraOffsetY <= 0 {
                self.cameraOffsetY = 0
                break
            }
        }

        while Int(self.player.y) + self.player.sprite.getMaxY() >= self.cameraOffsetY + self.contentView.height {
            if self.cameraOffsetY >= self.level.height - self.contentView.height {
                break
            }

            self.cameraOffsetY += self.contentView.height - self.player.sprite.getHeight() + 1
            fullRender = true

            if self.cameraOffsetY >= self.level.height - self.contentView.height {
                self.cameraOffsetY = self.level.height - self.contentView.height
                break
            }
        }

        if fullRender {
            self.render()
        }
    }

    func render() {
        var pixels: Set<Pixel> = []

        for y in 0..<self.contentView.height {
            for x in 0..<self.contentView.width {
                pixels.insert(Pixel(x: self.cameraOffsetX + x, y: self.cameraOffsetY + y))
            }
        }

        self.render(pixels: pixels)
    }

    func render(pixels: Set<Pixel>) {
        if pixels.isEmpty {
            return
        }

        Utils.synchronized(self.pendingPaint as AnyObject) { () -> Void in
            self.pendingPaint = pixels.union(self.pendingPaint)
        }
    }

    func paint() {
        if self.painting {
            return
        }

        self.painting = true

        self.paintThread.async {
            var minX = self.contentView.width, maxX = 0
            var minY = self.contentView.height, maxY = 0

            Utils.synchronized(self.pendingPaint as AnyObject) { () -> Void in
                for pixel in self.pendingPaint {
                    let x = pixel.x - self.cameraOffsetX, y = pixel.y - self.cameraOffsetY
                    if x < 0 || x >= self.contentView.width || y < 0 || y >= self.contentView.height {
                        continue
                    }

                    if x < minX {
                        minX = x
                    }
                    if x > maxX {
                        maxX = x
                    }
                    if y < minY {
                        minY = y
                    }
                    if y > maxY {
                        maxY = y
                    }
                }
                self.pendingPaint = []
            }

            if minX > maxX || minY > maxY {
                self.painting = false
                return
            }

            let entities = self.entities.filter({ (entity) -> Bool in
                if maxX + self.cameraOffsetX < Int(entity.x) + entity.sprite.getMinX() {
                    return false
                }
                if minX + self.cameraOffsetX > Int(entity.x) + entity.sprite.getMaxX() + 1 {
                    return false
                }
                if maxY + self.cameraOffsetY < Int(entity.y) + entity.sprite.getMinY() {
                    return false
                }
                if minY + self.cameraOffsetY > Int(entity.y) + entity.sprite.getMaxY() + 1 {
                    return false
                }

                return true
            })

            DispatchQueue.main.sync {
                for x in minX + self.cameraOffsetX...maxX + self.cameraOffsetX {
                    for y in minY + self.cameraOffsetY...maxY + self.cameraOffsetY {
                        var color = self.level.background.getColor(x: x, y: y)
                        for entity in entities {
                            color = Utils.blend(color: entity.sprite.getColor(x: x - Int(entity.x), y: y - Int(entity.y)), above: color)
                        }
                        color = Utils.blend(color: self.player.sprite.getColor(x: x - Int(self.player.x), y: y - Int(self.player.y)), above: color)
                        self.contentView.paint(x: x - self.cameraOffsetX, y: y - self.cameraOffsetY, color: color, absolute: true, update: false)
                    }
                }

                let pixelSize = max(floor(min(self.contentView.frame.width / CGFloat(self.contentView.width), self.contentView.frame.height / CGFloat(self.contentView.height))), 1)
                let offsetX = (self.contentView.frame.width - pixelSize * CGFloat(self.contentView.width)) / 2
                let offsetY = (self.contentView.frame.height - pixelSize * CGFloat(self.contentView.height)) / 2

                let py = CGFloat(self.contentView.frame.height) - (offsetY + CGFloat(maxY + 1) * pixelSize)
                let px = offsetX + CGFloat(minX) * pixelSize

                self.contentView.setNeedsDisplay(NSRect(x: px, y: py, width: CGFloat(maxX - minX + 1) * pixelSize, height: CGFloat(maxY - minY + 1) * pixelSize))
                self.painting = false
            }
        }
    }

}

