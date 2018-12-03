//
//  Utils.swift
//  TheAlpacaSacrifice
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 TheAlpacaSacrifice. All rights reserved.
//

import Foundation

class Utils {

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

    static func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        return try body()
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

