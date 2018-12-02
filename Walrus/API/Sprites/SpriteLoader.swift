//
//  SpriteLoader.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Foundation

extension Sprite {

    static var spritesInfo: [String: AnyObject]?
    static var loadedSprites: [String: Sprite] = [:]

    static func loadAll() -> [String: Sprite?] {
        if Sprite.spritesInfo == nil {
            if let path = Bundle.main.path(forResource: "Sprites", ofType: "plist") {
                Sprite.spritesInfo = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
            }
        }

        var sprites: [String: Sprite?] = [:]

        guard let spritesInfo = Sprite.spritesInfo else {
            return sprites
        }

        for name in spritesInfo.keys {
            guard let spriteInfo = spritesInfo[name] as? [String: AnyObject] else {
                continue
            }

            sprites[name] = Sprite.load(name: name, info: spriteInfo)
        }

        return sprites
    }

    static func load(name: String) -> Sprite? {
        if self.loadedSprites[name] != nil {
            if let sprite = (loadedSprites[name] as? NSCopying)?.copy() as? Sprite {
                return sprite
            }
            return loadedSprites[name]
        }

        if Sprite.spritesInfo == nil {
            if let path = Bundle.main.path(forResource: "Sprites", ofType: "plist") {
                Sprite.spritesInfo = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
            }
        }

        guard let spritesInfo = Sprite.spritesInfo, let spriteInfo = spritesInfo[name] as? [String: AnyObject] else {
            return nil
        }

        return Sprite.load(name: name, info: spriteInfo)
    }

    static func load(name: String, info spriteInfo: [String: AnyObject]) -> Sprite? {
        switch spriteInfo["type"] as? String {
        case "status":
            guard let statusesInfo = spriteInfo["statuses"] as? [String: AnyObject] else {
                return nil
            }

            var statuses: [String: Sprite] = [:]

            for status in statusesInfo.keys {
                if let name = statusesInfo[status] as? String, let sprite = Sprite.load(name: name) {
                    statuses[status] = sprite
                } else if let statusInfo = statusesInfo[status] as? [String: AnyObject], let sprite = Sprite.load(name: name + "." + status, info: statusInfo) {
                    statuses[status] = sprite
                }
            }

            let sprite = StatusSprite(name: name, sprites: statuses)
            self.loadedSprites[name] = sprite
            return sprite.copy() as! StatusSprite

        case "tiling":
            guard let tile = Sprite.load(name: "Tile@" + name, info: spriteInfo.filter({ (entry) -> Bool in entry.0 != "type" })) else {
                return nil
            }

            let sprite = TilingSprite(name: name, tile: tile)
            self.loadedSprites[name] = sprite
            return sprite

        case nil:
            guard let file = spriteInfo["file"] as? String, let ext = spriteInfo["extension"] as? String else {
                return nil
            }

            guard var anchorX = spriteInfo["anchorX"] as? Int, var anchorY = spriteInfo["anchorY"] as? Int else {
                return nil
            }

            guard let path = Bundle.main.path(forResource: file, ofType: ext) else {
                return nil
            }

            guard let source = CGDataProvider(url: NSURL(fileURLWithPath: path)) else {
                return nil
            }

            guard let image = CGImage(pngDataProviderSource: source, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
                return nil
            }

            guard let data = CFDataGetBytePtr(image.dataProvider?.data) else {
                return nil
            }

            var cropX = 0, cropY = 0, cropWidth = image.width, cropHeight = image.height

            if let rcrop = spriteInfo["crop"] as? [String: AnyObject] {
                if let rcropX = rcrop["x"] as? Int {
                    cropX = rcropX
                }

                if let rcropY = rcrop["y"] as? Int {
                    cropY = rcropY
                }

                if let rcropWidth = rcrop["width"] as? Int {
                    cropWidth = rcropWidth
                }

                if let rcropHeight = rcrop["height"] as? Int {
                    cropHeight = rcropHeight
                }
            }

            var pixels: [[CGColor]] = []

            for y in cropY..<cropY + cropHeight {
                var line: [CGColor] = []
                for x in cropX..<cropX + cropWidth {
                    let pixelInfo = (image.width * y + x) * 4

                    let r = CGFloat(data[pixelInfo + 0]) / 255
                    let g = CGFloat(data[pixelInfo + 1]) / 255
                    let b = CGFloat(data[pixelInfo + 2]) / 255
                    let a = CGFloat(data[pixelInfo + 3]) / 255

                    line.append(CGColor(red: r, green: g, blue: b, alpha: a))
                }
                pixels.append(line)
            }

            while !pixels.isEmpty {
                var empty = true
                for x in 0..<pixels.first!.count {
                    if pixels.first![x].alpha > 0 {
                        empty = false
                        break
                    }
                }

                if empty {
                    pixels.remove(at: 0)
                    anchorY -= 1
                } else {
                    break
                }
            }

            while !pixels.isEmpty {
                var empty = true
                for x in 0..<pixels.last!.count {
                    if pixels.last![x].alpha > 0 {
                        empty = false
                        break
                    }
                }

                if empty {
                    pixels.remove(at: pixels.count - 1)
                } else {
                    break
                }
            }

            while !(pixels.first?.isEmpty ?? true) {
                var empty = true
                for y in 0..<pixels.count {
                    if pixels[y].first!.alpha > 0 {
                        empty = false
                        break
                    }
                }

                if empty {
                    for y in 0..<pixels.count {
                        pixels[y].remove(at: 0)
                    }
                    anchorX -= 1
                } else {
                    break
                }
            }

            while !(pixels.first?.isEmpty ?? true) {
                var empty = true
                for y in 0..<pixels.count {
                    if pixels[y].last!.alpha > 0 {
                        empty = false
                        break
                    }
                }

                if empty {
                    for y in 0..<pixels.count {
                        pixels[y].remove(at: pixels[y].count - 1)
                    }
                } else {
                    break
                }
            }

            if pixels.first?.isEmpty ?? false {
                pixels.removeAll()
            }

            let sprite = Sprite(name: name, pixels: pixels, anchorX: anchorX, anchorY: anchorY)
            self.loadedSprites[name] = sprite
            return sprite

        default:
            return nil
        }
    }

}

