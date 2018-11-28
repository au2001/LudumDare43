//
//  ContentView.swift
//  Walrus
//
//  Created by Aurélien on 27/11/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Cocoa

class ContentView: NSView {

    var game: Game?

    let width = 256, height = 192
    var pixels: [[NSView]] = []

    override func viewDidMoveToWindow() {
        let pixelSize = max(floor(min(self.frame.width / CGFloat(self.width), self.frame.height / CGFloat(self.height))), 1)
        let offsetX = (self.frame.width - pixelSize * CGFloat(self.width)) / 2
        let offsetY = (self.frame.height - pixelSize * CGFloat(self.height)) / 2

        for y in 0..<height {
            pixels.append([])
            let py = CGFloat(self.frame.height) - (offsetY + CGFloat(y + 1) * pixelSize)

            for x in 0..<width {
                let frame = NSRect(x: offsetX + CGFloat(x) * pixelSize, y: py, width: pixelSize, height: pixelSize)
                let view = NSView(frame: frame)
                view.wantsLayer = true
                pixels[y].append(view)
                self.addSubview(view)
            }
        }

        self.game = Game.init(contentView: self)
        self.game?.start()
    }

    func paint(x: Int, y: Int, color: CGColor) {
        if color.alpha <= 0 {
            return
        }

        let previousColor = pixels[y][x].layer?.backgroundColor ?? .clear

        if color.alpha >= 1 || previousColor.alpha == 0 {
            pixels[y][x].layer?.backgroundColor = color
            return
        }

        let pr = previousColor.components?[0] ?? 0, nr = color.components?[0] ?? 0
        let pg = previousColor.components?[1] ?? 0, ng = color.components?[1] ?? 0
        let pb = previousColor.components?[2] ?? 0, nb = color.components?[2] ?? 0

        let r = pr * (1 - color.alpha) + nr * color.alpha
        let g = pg * (1 - color.alpha) + ng * color.alpha
        let b = pb * (1 - color.alpha) + nb * color.alpha
        let a = min(previousColor.alpha + color.alpha, 1)

        pixels[y][x].layer?.backgroundColor = CGColor(red: r, green: g, blue: b, alpha: a)
    }

    func paintRect(x: Int, y: Int, width: Int, height: Int, color: CGColor) {
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
    }

    func paintSprite(x: Int, y: Int, sprite: Sprite) {
        for x1 in sprite.getMinX()...sprite.getMaxX() {
            if x + x1 < 0 || x + x1 >= self.width {
                continue
            }

            for y1 in sprite.getMinY()...sprite.getMaxY() {
                if y + y1 < 0 || y + y1 >= self.height {
                    continue
                }

                self.paint(x: x + x1, y: y + y1, color: sprite.getColor(x: x1, y: y1))
            }
        }
    }

    override func keyDown(with event: NSEvent) {
        self.game?.keyPress(event: event)

        if !event.isARepeat {
            self.game?.keyDown(event: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        self.game?.keyUp(event: event)
    }
    
}

