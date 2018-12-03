//
//  GameMenu.swift
//  Walrus
//
//  Created by Aurélien on 03/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class GameMenu: Interface {

    let contentView: ContentView
    let score: Int

    let background: Sprite
    let logo: Sprite
    let playButton: Sprite
    let quitButton: Sprite

    let scoreText: NSTextField?

    let pixelSize: Int
    let offsetX, offsetY: Int

    var displayLink: CVDisplayLink?
    let paintThread = DispatchQueue(label: "PaintThreadQueue")
    
    var pendingPaint: Set<Pixel> = []
    var painting = false

    var clicked: String?

    required convenience init(contentView: ContentView) {
        self.init(score: -1, contentView: contentView)
    }

    init(score: Int, contentView: ContentView) {
        self.contentView = contentView
        self.score = score

        self.background = CombinedSprite(sprites: [
            (sprite: Sprite.load(name: "background") ?? Sprite.EMPTY, position: Pixel(x: 0, y: 0)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 50, y: 60)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 90, y: 120)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 130, y: 40)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 200, y: 100)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 230, y: 50)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 310, y: 110)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 320, y: 50)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 60, y: 180)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 140, y: 200)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 210, y: 210)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 260, y: 160)),
            (sprite: Sprite.load(name: "tree1") ?? Sprite.EMPTY, position: Pixel(x: 320, y: 190))
        ])
        self.logo = Sprite.load(name: "logo") ?? Sprite.EMPTY
        self.playButton = Sprite.load(name: "play_button") ?? Sprite.EMPTY
        self.quitButton = Sprite.load(name: "quit_button") ?? Sprite.EMPTY

        self.pixelSize = Int(max(floor(min(self.contentView.frame.width / CGFloat(self.contentView.width), self.contentView.frame.height / CGFloat(self.contentView.height))), 1))
        self.offsetX = Int((self.contentView.frame.width - CGFloat(self.pixelSize * self.contentView.width)) / 2)
        self.offsetY = Int((self.contentView.frame.height - CGFloat(self.pixelSize * self.contentView.height)) / 2)

        if score >= 0 {
            let y = self.contentView.frame.height * CGFloat(self.contentView.height - 120) / CGFloat(self.contentView.height) - CGFloat(self.offsetX)
            self.scoreText = NSTextField(labelWithString: "You scored: " + String(describing: score))
            self.scoreText?.font = NSFont(name: "Herculanum", size: 54)
            self.scoreText?.frame = NSRect(x: 0, y: y, width: self.contentView.frame.width, height: CGFloat(50 * self.pixelSize))
            self.scoreText?.alignment = .center
            self.contentView.addSubview(self.scoreText!)
        } else {
            self.scoreText = nil
        }

        self.render()
        self.start()
    }

    func start() {
        if self.displayLink == nil {
            CVDisplayLinkCreateWithActiveCGDisplays(&self.displayLink)

            if let displayLink = self.displayLink {
                let displayLinkOutputCallback: CVDisplayLinkOutputCallback = { (displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
                    let menu = unsafeBitCast(displayLinkContext, to: GameMenu.self)
                    menu.paint()
                    return kCVReturnSuccess
                }

                CVDisplayLinkSetOutputCallback(displayLink, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
                CVDisplayLinkStart(displayLink)
            }
        }
    }

    func stop() {
        self.scoreText?.removeFromSuperview()
        if let displayLink = self.displayLink {
            CVDisplayLinkStop(displayLink)
        }
        self.displayLink = nil
    }

    func keyPress(event: NSEvent) {
        // TODO: Control menu with arrow keys
    }

    func keyDown(event: NSEvent) {}
    func keyUp(event: NSEvent) {}

    func mouseMoved(event: NSEvent) {
        let x = Int((Int(event.locationInWindow.x) - self.offsetX) / pixelSize)
        let y = Int((Int(self.contentView.frame.height - event.locationInWindow.y) + self.offsetY) / pixelSize)

        if let playButton = self.playButton as? StatusSprite {
            if playButton.isHitBox(x: x, y: y, threshold: 0) {
                if playButton.status != "hover" {
                    playButton.status = "hover"
                    self.render(pixels: playButton.getViewBox())
                }
            } else {
                if playButton.status != "default" {
                    playButton.status = "default"
                    self.render(pixels: playButton.getViewBox())
                }

                if self.clicked == "play" {
                    self.clicked = nil
                }
            }
        }

        if let quitButton = self.quitButton as? StatusSprite {
            if quitButton.isHitBox(x: x, y: y, threshold: 0) {
                if quitButton.status != "hover" {
                    quitButton.status = "hover"
                    self.render(pixels: quitButton.getViewBox())
                }
            } else {
                if quitButton.status != "default" {
                    quitButton.status = "default"
                    self.render(pixels: quitButton.getViewBox())
                }

                if self.clicked == "quit" {
                    self.clicked = nil
                }
            }
        }
    }

    func mouseDown(event: NSEvent) {
        let x = Int((Int(event.locationInWindow.x) - self.offsetX) / pixelSize)
        let y = Int((Int(self.contentView.frame.height - event.locationInWindow.y) + self.offsetY) / pixelSize)

        if self.playButton.isHitBox(x: x, y: y, threshold: 0) {
            self.clicked = "play"
        } else if self.quitButton.isHitBox(x: x, y: y, threshold: 0) {
            self.clicked = "quit"
        } else {
            self.clicked = nil
        }
    }

    func mouseUp(event: NSEvent) {
        if self.clicked == "play" {
            self.play()
        } else if self.clicked == "quit" {
            self.quit()
        }
    }

    func play() {
        self.stop()
        self.contentView.interface = Game(contentView: self.contentView)
    }

    func quit() {
        NSApplication.shared.terminate(self)
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

        Utils.synchronized(self.pendingPaint as AnyObject) { () -> Void in
            self.pendingPaint = pixels.union(self.pendingPaint)
        }
    }

    func paint() {
        if self.painting || self.pendingPaint.isEmpty {
            return
        }

        self.painting = true

        self.paintThread.async {
            var minX = self.contentView.width, maxX = 0
            var minY = self.contentView.height, maxY = 0

            Utils.synchronized(self.pendingPaint as AnyObject) { () -> Void in
                for pixel in self.pendingPaint {
                    if pixel.x < 0 || pixel.x >= self.contentView.width || pixel.y < 0 || pixel.y >= self.contentView.height {
                        continue
                    }

                    if pixel.x < minX {
                        minX = pixel.x
                    }
                    if pixel.x > maxX {
                        maxX = pixel.x
                    }
                    if pixel.y < minY {
                        minY = pixel.y
                    }
                    if pixel.y > maxY {
                        maxY = pixel.y
                    }
                }
                self.pendingPaint = []
            }

            if minX > maxX || minY > maxY {
                self.painting = false
                return
            }

            DispatchQueue.main.sync {
                for x in minX...maxX {
                    for y in minY...maxY {
                        var color = self.background.getColor(x: x, y: y)
                        color = Utils.blend(color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.5), above: color)

                        color = Utils.blend(color: self.logo.getColor(x: x, y: y), above: color)
                        color = Utils.blend(color: self.playButton.getColor(x: x, y: y), above: color)
                        color = Utils.blend(color: self.quitButton.getColor(x: x, y: y), above: color)

                        self.contentView.paint(x: x, y: y, color: color, absolute: true, update: false)
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

