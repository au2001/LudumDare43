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
        let pw = self.frame.width / CGFloat(self.width)
        let ph = self.frame.height / CGFloat(self.height)

        for y in 0..<height {
            pixels.append([])
            for x in 0..<width {
                let frame = NSRect(x: CGFloat(x) * pw, y: CGFloat(y) * ph, width: pw, height: ph)
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
        pixels[self.height - y - 1][x].layer?.backgroundColor = color
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
            for y1 in sprite.getMinY()...sprite.getMaxY() {
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

