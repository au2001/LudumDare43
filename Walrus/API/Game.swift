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

        self.render()
    }

    func start() {
        if self.displayLink == nil {
            self.lastTick = Date().timeIntervalSinceReferenceDate
            CVDisplayLinkCreateWithActiveCGDisplays(&self.displayLink)

            if let displayLink = self.displayLink {
                let displayLinkOutputCallback: CVDisplayLinkOutputCallback = { (displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
                    let game = unsafeBitCast(displayLinkContext, to: Game.self)
                    game.tick()
                    game.paint()
                    return kCVReturnSuccess
                }

                CVDisplayLinkSetOutputCallback(displayLink, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
                CVDisplayLinkStart(displayLink)
            }
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
    }

    func render() {
        var pixels: Set<Pixel> = []

        for y in 0..<self.contentView.height {
            for x in 0..<self.contentView.width {
                pixels.insert(Pixel(x: x, y: y))
            }
        }

        self.render(pixels: pixels)
    }

    func render(pixels: Set<Pixel>) {
        if pixels.isEmpty {
            return
        }

        self.pendingPaint.formUnion(pixels)
    }

    func paint() {
        if self.pendingPaint.isEmpty {
            return
        }

        if self.painting {
            return
        }

        self.painting = true

        DispatchQueue.main.async {
            var minX = self.contentView.width, maxX = 0
            var minY = self.contentView.height, maxY = 0

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

                var color = self.background.getColor(x: pixel.x, y: pixel.y)
                for entity in self.entities {
                    color = ContentView.blend(color: entity.sprite.getColor(x: pixel.x - Int(entity.x), y: pixel.y - Int(entity.y)), above: color)
                }
                color = ContentView.blend(color: self.player.sprite.getColor(x: pixel.x - Int(self.player.x), y: pixel.y - Int(self.player.y)), above: color)
                self.contentView.paint(x: x, y: y, color: color, absolute: true, update: false)
            }

            let pixelSize = max(floor(min(self.contentView.frame.width / CGFloat(self.contentView.width), self.contentView.frame.height / CGFloat(self.contentView.height))), 1)
            let offsetX = (self.contentView.frame.width - pixelSize * CGFloat(self.contentView.width)) / 2
            let offsetY = (self.contentView.frame.height - pixelSize * CGFloat(self.contentView.height)) / 2

            let py = CGFloat(self.contentView.frame.height) - (offsetY + CGFloat(maxY + 1) * pixelSize)
            let px = offsetX + CGFloat(minX) * pixelSize
            self.contentView.setNeedsDisplay(NSRect(x: px, y: py, width: CGFloat(maxX - minX + 1) * pixelSize, height: CGFloat(maxY - minY + 1) * pixelSize))

            self.pendingPaint.removeAll()
            self.painting = false
        }
    }

}

class Pixel: Hashable {

    static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    let x, y: Int

    public var hashValue: Int {
        get {
            return self.x << 32 | self.x >> (Int.bitWidth - 32) | self.y
        }
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

}

