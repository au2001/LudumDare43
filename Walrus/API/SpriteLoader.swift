//
//  SpriteLoader.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Foundation

extension Sprite {

    static var spritesInfo: [String: [String: AnyObject]]?
    static var loadedSprites: [String: Sprite] = [:]

    static func load(name: String) -> Sprite? {
        if self.loadedSprites[name] != nil {
            return loadedSprites[name]
        }

        if Sprite.spritesInfo == nil {
            if let path = Bundle.main.path(forResource: "Sprites", ofType: "plist") {
                Sprite.spritesInfo = NSDictionary(contentsOfFile: path) as? [String: [String: AnyObject]]
            }
        }

        guard let spritesInfo = Sprite.spritesInfo, let spriteInfo = spritesInfo[name] else {
            return nil
        }

        guard let file = spriteInfo["file"] as? String, let type = spriteInfo["type"] as? String else {
            return nil
        }

        guard let anchorX = spriteInfo["anchorX"] as? Int, let anchorY = spriteInfo["anchorY"] as? Int else {
            return nil
        }

        guard let path = Bundle.main.path(forResource: file, ofType: type) else {
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

        var pixels: [[CGColor]] = []

        for y in 0..<image.height {
            pixels.append([])
            for x in 0..<image.width {
                let pixelInfo = (image.width * y + x) * 4

                let r = CGFloat(data[pixelInfo + 0]) / 255
                let g = CGFloat(data[pixelInfo + 1]) / 255
                let b = CGFloat(data[pixelInfo + 2]) / 255
                let a = CGFloat(data[pixelInfo + 3]) / 255

                pixels[y].append(CGColor(red: r, green: g, blue: b, alpha: a))
            }
        }

        let sprite = Sprite(pixels: pixels, anchorX: anchorX, anchorY: anchorY)
        self.loadedSprites[name] = sprite
        return sprite
    }

}

