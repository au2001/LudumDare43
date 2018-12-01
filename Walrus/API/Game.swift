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
    var keysDown: [UInt16] = []

    let controls = Controls()
    var lastTick: TimeInterval = 0

    var pendingPaint: Set<Pixel> = []
    var painting = false

    var entities: [Entity] = []
    var cameraOffsetX = 0, cameraOffsetY = 0
    let background: Sprite

    let player: Entity

    init(level: Level, contentView: ContentView) {
        self.level = level
        self.contentView = contentView
        self.background = Sprite.load(name: "background")!

        for entity in level.entities {
            self.entities.append(Entity(sprite: entity.sprite, x: entity.x, y: entity.y))
        }

        self.player = Entity(sprite: Sprite.load(name: "character")!, x: Double(self.contentView.width) / 2, y: Double(self.contentView.height) / 2)

        self.tick()
        self.render()
    }

    func start() {
        if self.displayLink == nil {
            self.lastTick = Date().timeIntervalSinceReferenceDate
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

    func keyPress(event: NSEvent) {}

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
        let now = Date().timeIntervalSince1970
        let delta = now - self.lastTick
        self.lastTick = now

        self.controls.tick(game: self, delta: delta)

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
            if self.cameraOffsetX >= self.level.width - self.contentView.width - 1 {
                break
            }

            self.cameraOffsetX += self.contentView.width - self.player.sprite.getWidth() + 1
            fullRender = true

            if self.cameraOffsetX >= self.level.width - self.contentView.width - 1 {
                self.cameraOffsetX = self.level.width - self.contentView.width - 1
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
            if self.cameraOffsetY >= self.level.height - self.contentView.height - 1 {
                break
            }

            self.cameraOffsetY += self.contentView.height - self.player.sprite.getHeight() + 1
            fullRender = true

            if self.cameraOffsetY >= self.level.height - self.contentView.height - 1 {
                self.cameraOffsetY = self.level.height - self.contentView.height - 1
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
            self.pendingPaint.formUnion(pixels)
        }
    }

    func paint() {
        if self.painting {
            return
        }

        self.painting = true
        var pendingPaint: Set<Pixel> = []

        Utils.synchronized(self.pendingPaint as AnyObject) { () -> Void in
            pendingPaint.formUnion(self.pendingPaint)
            self.pendingPaint.removeAll()
        }

        if pendingPaint.isEmpty {
            self.painting = false
            return
        }

        DispatchQueue.main.sync {
            var minX = self.contentView.width, maxX = 0
            var minY = self.contentView.height, maxY = 0

            for pixel in pendingPaint {
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

                var color = self.background.getColor(x: pixel.x, y: pixel.y)
                for entity in self.entities {
                    color = Utils.blend(color: entity.sprite.getColor(x: pixel.x - Int(entity.x), y: pixel.y - Int(entity.y)), above: color)
                }
                color = Utils.blend(color: self.player.sprite.getColor(x: pixel.x - Int(self.player.x), y: pixel.y - Int(self.player.y)), above: color)
                self.contentView.paint(x: x, y: y, color: color, absolute: true, update: false)
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

