//
//  ContentView.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class ContentView: NSImageView {

    var game: Game?

    let width = 360, height = 225
    var pixels: [[CGColor]] = []

    override func viewDidMoveToWindow() {
        self.wantsLayer = true

        for y in 0..<height {
            self.pixels.append([])
            for _ in 0..<width {
                self.pixels[y].append(.clear)
            }
        }

        self.game = Game.init(contentView: self)
        self.game?.start()
    }

    static func blend(color: CGColor, above previousColor: CGColor) -> CGColor {
        if color.alpha <= 0 {
            return previousColor
        }

        if color.alpha >= 1 || previousColor.alpha == 0 {
            return color
        }

        let pr = previousColor.components?[0] ?? 0, nr = color.components?[0] ?? 0
        let pg = previousColor.components?[1] ?? 0, ng = color.components?[1] ?? 0
        let pb = previousColor.components?[2] ?? 0, nb = color.components?[2] ?? 0

        let r = pr * (1 - color.alpha) + nr * color.alpha
        let g = pg * (1 - color.alpha) + ng * color.alpha
        let b = pb * (1 - color.alpha) + nb * color.alpha
        let a = min(color.alpha + previousColor.alpha, 1)

        return CGColor(red: r, green: g, blue: b, alpha: a)
    }

    func paint(x: Int, y: Int, color: CGColor, absolute: Bool = false, update: Bool = true) {
        if absolute {
            self.pixels[y][x] = color
        } else {
            self.pixels[y][x] = ContentView.blend(color: color, above: self.pixels[y][x])
        }

        if update {
            let pixelSize = max(floor(min(self.frame.width / CGFloat(self.width), self.frame.height / CGFloat(self.height))), 1)
            let offsetX = (self.frame.width - pixelSize * CGFloat(self.width)) / 2
            let offsetY = (self.frame.height - pixelSize * CGFloat(self.height)) / 2

            let py = CGFloat(self.frame.height) - (offsetY + CGFloat(y + 1) * pixelSize)
            let px = offsetX + CGFloat(x) * pixelSize
            self.setNeedsDisplay(NSRect(x: px, y: py, width: pixelSize, height: pixelSize))
        }
    }

    func paintRect(x: Int, y: Int, width: Int, height: Int, color: CGColor, absolute: Bool = false, update: Bool = true) {
        var x = x, y = y, width = width, height = height
        if width < 0 {
            x -= width
            width *= -1
        }

        if height < 0 {
            y -= height
            height *= -1
        }

        for x1 in 0..<width {
            if x + x1 < 0 || x + x1 >= self.width {
                continue
            }

            for y1 in 0..<height {
                if y + y1 < 0 || y + y1 >= self.height {
                    continue
                }

                self.paint(x: x + x1, y: y + y1, color: color)
            }
        }

        if update {
            let pixelSize = max(floor(min(self.frame.width / CGFloat(self.width), self.frame.height / CGFloat(self.height))), 1)
            let offsetX = (self.frame.width - pixelSize * CGFloat(self.width)) / 2
            let offsetY = (self.frame.height - pixelSize * CGFloat(self.height)) / 2

            let py = CGFloat(self.frame.height) - (offsetY + CGFloat(y + 1) * pixelSize)
            let px = offsetX + CGFloat(x) * pixelSize
            self.setNeedsDisplay(NSRect(x: px, y: py, width: CGFloat(width) * pixelSize, height: CGFloat(height) * pixelSize))
        }
    }

    func paintSprite(x: Int, y: Int, sprite: Sprite, absolute: Bool = false, update: Bool = true) {
        for x1 in sprite.getMinX()...sprite.getMaxX() {
            if x + x1 < 0 || x + x1 >= self.width {
                continue
            }

            for y1 in sprite.getMinY()...sprite.getMaxY() {
                if y + y1 < 0 || y + y1 >= self.height {
                    continue
                }

                self.paint(x: x + x1, y: y + y1, color: sprite.getColor(x: x1, y: y1), absolute: absolute, update: false)
            }
        }

        if update {
            let pixelSize = max(floor(min(self.frame.width / CGFloat(self.width), self.frame.height / CGFloat(self.height))), 1)
            let offsetX = (self.frame.width - pixelSize * CGFloat(self.width)) / 2
            let offsetY = (self.frame.height - pixelSize * CGFloat(self.height)) / 2

            let py = CGFloat(self.frame.height) - (offsetY + CGFloat(y + sprite.getMaxY() + 1) * pixelSize)
            let px = offsetX + CGFloat(x + sprite.getMinX()) * pixelSize
            self.setNeedsDisplay(NSRect(x: px, y: py, width: CGFloat(sprite.getWidth()) * pixelSize, height: CGFloat(sprite.getHeight()) * pixelSize))
        }
    }

    override func keyDown(with event: NSEvent) {
        if !event.isARepeat {
            self.game?.keyDown(event: event)
        }

        self.game?.keyPress(event: event)
    }

    override func keyUp(with event: NSEvent) {
        self.game?.keyUp(event: event)
    }

    override func draw(_ rect: NSRect) {
        let pixelSize = max(floor(min(self.frame.width / CGFloat(self.width), self.frame.height / CGFloat(self.height))), 1)
        let offsetX = (self.frame.width - pixelSize * CGFloat(self.width)) / 2
        let offsetY = (self.frame.height - pixelSize * CGFloat(self.height)) / 2

        let x1 = (rect.minX - offsetX - (rect.minX - offsetX).truncatingRemainder(dividingBy: pixelSize)) / pixelSize
        let rx = (rect.maxX - offsetX).remainder(dividingBy: pixelSize)
        var x2 = (rect.maxX - offsetX - rx) / pixelSize
        if rx > 0 {
            x2 += pixelSize
        }

        let y1 = (CGFloat(self.frame.height) - rect.maxY + offsetY - (CGFloat(self.frame.height) - rect.maxY + offsetY).truncatingRemainder(dividingBy: pixelSize)) / pixelSize
        let ry = (CGFloat(self.frame.height) - rect.minY + offsetY).remainder(dividingBy: pixelSize)
        var y2 = (CGFloat(self.frame.height) - rect.minY + offsetY - ry) / pixelSize
        if ry > 0 {
            y2 += pixelSize
        }

        for y in Int(y1)..<Int(y2) {
            let py = CGFloat(self.frame.height) - (offsetY + CGFloat(y + 1) * pixelSize)

            for x in Int(x1)..<Int(x2) {
                let px = offsetX + CGFloat(x) * pixelSize

                NSColor(cgColor: self.pixels[y][x])?.set()
                let path = NSRect(x: px, y: py, width: pixelSize, height: pixelSize)
                path.fill()
            }
        }
    }
    
}

