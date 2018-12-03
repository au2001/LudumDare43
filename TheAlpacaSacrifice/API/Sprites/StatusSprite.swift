//
//  StatusSprite.swift
//  TheAlpacaSacrifice
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 TheAlpacaSacrifice. All rights reserved.
//

import Cocoa

class StatusSprite: Sprite, NSCopying {

    static var CURRENT_ID = -1
    static var NEXT_ID: String {
        CombinedSprite.CURRENT_ID += 1
        return String(CombinedSprite.CURRENT_ID, radix: 16, uppercase: false)
    }

    var sprites: [String: Sprite]
    var status: String?
    var defaultStatus: String?

    convenience init(sprites: [String: Sprite], status: String? = nil) {
        self.init(name: "StatusSprite@" + StatusSprite.NEXT_ID, sprites: sprites, status: status)
    }

    init(name: String, sprites: [String: Sprite], status: String? = nil) {
        self.sprites = sprites
        self.status = status
        self.defaultStatus = status

        super.init(name: name, pixels: [], anchorX: 0, anchorY: 0)
    }

    func add(sprite: Sprite, for status: String, asCurrent current: Bool = false) {
        self.sprites[status] = sprite

        if current {
            self.status = status
        }
    }

    func remove(for status: String) {
        self.sprites.removeValue(forKey: status)
    }

    func getDefault() -> Sprite? {
        if let defaultStatus = self.defaultStatus, let sprite = self.sprites[defaultStatus] {
            return sprite
        }
        return nil
    }

    func getCurrent() -> Sprite? {
        if let status = self.status, let sprite = self.sprites[status] {
            return sprite
        }
        return nil
    }

    override func getWidth() -> Int {
        return self.getCurrent()?.getWidth() ?? 0
    }

    override func getHeight() -> Int {
        return self.getCurrent()?.getHeight() ?? 0
    }

    override func getMinX() -> Int {
        return self.getCurrent()?.getMinX() ?? 0
    }

    override func getMinY() -> Int {
        return self.getCurrent()?.getMinY() ?? 0
    }

    override func getMaxX() -> Int {
        return self.getCurrent()?.getMaxX() ?? 0
    }

    override func getMaxY() -> Int {
        return self.getCurrent()?.getMaxY() ?? 0
    }

    override func getColor(x: Int, y: Int) -> CGColor {
        return self.getCurrent()?.getColor(x: x, y: y) ?? .clear
    }

    override func getViewBox() -> Set<Pixel> {
        return self.getCurrent()?.getViewBox() ?? []
    }

    override func isHitBox(x: Int, y: Int, threshold: Double) -> Bool {
        return (self.getDefault() ?? self.getCurrent())?.isHitBox(x: x, y: y, threshold: threshold) ?? false
    }

    override func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        return (self.getDefault() ?? self.getCurrent())?.getHitBox(threshold: threshold) ?? []
    }

    func copy(with zone: NSZone? = nil) -> Any {
        var name = self.name
        do {
            let results = try NSRegularExpression(pattern: " \\(copy( \\d+)?\\)$").matches(in: name, range: NSRange(name.startIndex..., in: name))
            if let result = results.first {
                if result.numberOfRanges > 1 {
                    let n = name[name.index(name.startIndex, offsetBy: result.range(at: 1).lowerBound)..<name.index(name.startIndex, offsetBy: result.range(at: 1).upperBound)]
                    name = String(name[...name.index(name.startIndex, offsetBy: result.range.lowerBound)]) + " (copy \(Int(n) ?? 0 + 1))"
                } else {
                    name = String(name[...name.index(name.startIndex, offsetBy: result.range.lowerBound)]) + " (copy 2)"
                }
            }
        } catch {}
        let copy = StatusSprite(name: name, sprites: self.sprites, status: self.status)
        return copy
    }

}

