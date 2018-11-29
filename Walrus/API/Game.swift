//
//  Game.swift
//  Walrus
//
//  Created by Aurélien on 28/11/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class Game {

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

    init(contentView: ContentView) {
        self.contentView = contentView
        self.background = Sprite.load(name: "background")!

        self.player = Entity(sprite: Sprite.load(name: "character")!)
        self.player.x = Double(self.contentView.width) / 2
        self.player.y = Double(self.contentView.height) / 2
        self.player.update(game: self)

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
            for pixel in self.pendingPaint {
                let x = pixel.x - self.cameraOffsetX, y = pixel.y - self.cameraOffsetY
                if x < 0 || x >= self.contentView.width || y < 0 || y >= self.contentView.height {
                    continue
                }

                self.contentView.paint(x: x, y: y, color: self.background.getColor(x: pixel.x, y: pixel.y))
                for entity in self.entities {
                    self.contentView.paint(x: x, y: y, color: entity.sprite.getColor(x: pixel.x - Int(entity.x), y: pixel.y - Int(entity.y)))
                }
                self.contentView.paint(x: x, y: y, color: self.player.sprite.getColor(x: pixel.x - Int(self.player.x), y: pixel.y - Int(self.player.y)))
            }

            self.pendingPaint.removeAll()
            self.painting = false
        }
    }

}

class Pixel: Hashable {

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

    static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

}

