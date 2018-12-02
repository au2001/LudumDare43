//
//  SpriteLoader.swift
//  Walrus
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 Walrus. All rights reserved.
//

import Foundation

extension Level {

    static func generateTemples(withSettings settings: GeneratorSettings) -> [TempleEntity] {
        var placements = [Int](0..<12)

        var temples: [TempleEntity] = []

        for _ in 0..<settings.templeCount {
            let x, y: Double

            if placements.isEmpty {
                break
            }

            let n = placements.remove(at: Int.random(in: 0..<placements.count))
            switch n {
            case 0: // Top left
                x = settings.templePaddingX - Double(settings.temple.getMinX())
                y = settings.templePaddingY - Double(settings.temple.getMinY())

            case 1: // Top center-left
                x = (Double(settings.width) - 2 * settings.templePaddingX) * 1 / 3
                y = settings.templePaddingY - Double(settings.temple.getMinY())

            case 2: // Top center-right
                x = (Double(settings.width) - 2 * settings.templePaddingX) * 2 / 3
                y = settings.templePaddingY - Double(settings.temple.getMinY())

            case 3: // Top right
                x = Double(settings.width) - Double(settings.temple.getMaxX()) - settings.templePaddingX
                y = settings.templePaddingY - Double(settings.temple.getMinY())

            case 4: // Middle-top right
                x = Double(settings.width) - Double(settings.temple.getMaxX()) - settings.templePaddingX
                y = (Double(settings.height) - 2 * settings.templePaddingY) * 1 / 3

            case 5: // Middle-bottom right
                x = Double(settings.width) - Double(settings.temple.getMaxX()) - settings.templePaddingX
                y = (Double(settings.height) - 2 * settings.templePaddingY) * 2 / 3

            case 6: // Bottom right
                x = Double(settings.width) - Double(settings.temple.getMaxX()) - settings.templePaddingX
                y = Double(settings.height) - Double(settings.temple.getMaxY()) - settings.templePaddingY

            case 7: // Bottom center-right
                x = (Double(settings.width) - 2 * settings.templePaddingX) * 2 / 3
                y = Double(settings.height) - Double(settings.temple.getMaxY()) - settings.templePaddingY

            case 8: // Bottom center-left
                x = (Double(settings.width) - 2 * settings.templePaddingX) * 1 / 3
                y = Double(settings.height) - Double(settings.temple.getMaxY()) - settings.templePaddingY

            case 9: // Bottom left
                x = settings.templePaddingX - Double(settings.temple.getMinX())
                y = Double(settings.height) - Double(settings.temple.getMaxY()) - settings.templePaddingY

            case 10: // Middle-bottom left
                x = settings.templePaddingX - Double(settings.temple.getMinX())
                y = (Double(settings.height) - 2 * settings.templePaddingY) * 2 / 3

            case 11: // Middle-top left
                x = settings.templePaddingX - Double(settings.temple.getMinX())
                y = (Double(settings.height) - 2 * settings.templePaddingY) * 1 / 3

            default:
                continue
            }

            for m in 0...settings.templeSpacing {
                if let index = placements.firstIndex(of: (n + m).quotientAndRemainder(dividingBy: 8).remainder) {
                    placements.remove(at: index)
                }
                if let index = placements.firstIndex(of: (n - m).quotientAndRemainder(dividingBy: 8).remainder) {
                    placements.remove(at: index)
                }
            }

            let temple = TempleEntity(sprite: settings.temple, x: x, y: y)
            temples.append(temple)
        }

        return temples
    }

    static func generateRoads(withSettings settings: GeneratorSettings, andTemples temples: [TempleEntity]) -> Set<Pixel> {
        var roads: Set<Pixel> = []

        for ry in 0...settings.roadSize / 2 {
            for rx in 0...settings.roadSize / 2 {
                if pow(Decimal(rx), 2) + pow(Decimal(ry), 2) > pow(Decimal(settings.roadSize) / 2, 2) {
                    continue
                }

                roads.insert(Pixel(x: rx, y: ry))
                if rx > 0 {
                    roads.insert(Pixel(x: -rx, y: ry))
                }
                if ry > 0 {
                    roads.insert(Pixel(x: rx, y: -ry))
                }
                if rx > 0 && ry > 0 {
                    roads.insert(Pixel(x: -rx, y: -ry))
                }
            }
        }

        for temple in temples {
            var horizontal = Bool.random()
            var x = Int(settings.spawnX), y = Int(settings.spawnY)

            while x != Int(temple.x) || y != Int(temple.y) {
                if horizontal {
                    if x < Int(temple.x) {
                        let length: Int
                        if Int(temple.x) - x >= settings.roadSize && y != Int(temple.y) {
                            length = Int.random(in: settings.roadSize...min(settings.maxRoadLengthX, Int(temple.x) - x))
                        } else {
                            length = Int(temple.x) - x
                        }

                        for rx in x..<x + length {
                            for ry in 0...settings.roadSize / 2 {
                                roads.insert(Pixel(x: rx, y: y + ry))
                                if ry > 0 {
                                    roads.insert(Pixel(x: rx, y: y - ry))
                                }
                            }
                        }

                        x += length

                        for rx in 0...settings.roadSize / 2 {
                            for ry in 0...settings.roadSize / 2 {
                                if pow(Decimal(rx), 2) + pow(Decimal(ry), 2) > pow(Decimal(settings.roadSize) / 2, 2) {
                                    continue
                                }

                                roads.insert(Pixel(x: x + rx, y: y + ry))
                                if ry > 0 {
                                    roads.insert(Pixel(x: x + rx, y: y - ry))
                                }
                            }
                        }
                    } else if x > Int(temple.x) {
                        let length: Int
                        if x - Int(temple.x) >= settings.roadSize && y != Int(temple.y) {
                            length = Int.random(in: settings.roadSize...min(settings.maxRoadLengthX, x - Int(temple.x)))
                        } else {
                            length = x - Int(temple.x)
                        }

                        for rx in x - length + 1...x {
                            for ry in 0...settings.roadSize / 2 {
                                roads.insert(Pixel(x: rx, y: y + ry))
                                if ry > 0 {
                                    roads.insert(Pixel(x: rx, y: y - ry))
                                }
                            }
                        }

                        x -= length

                        for rx in 0...settings.roadSize / 2 {
                            for ry in 0...settings.roadSize / 2 {
                                if pow(Decimal(rx), 2) + pow(Decimal(ry), 2) > pow(Decimal(settings.roadSize) / 2, 2) {
                                    continue
                                }

                                roads.insert(Pixel(x: x - rx, y: y + ry))
                                if ry > 0 {
                                    roads.insert(Pixel(x: x - rx, y: y - ry))
                                }
                            }
                        }
                    }
                } else {
                    if y < Int(temple.y) {
                        let length: Int
                        if Int(temple.y) - y >= settings.roadSize && x != Int(temple.x) {
                            length = Int.random(in: settings.roadSize...min(settings.maxRoadLengthY, Int(temple.y) - y))
                        } else {
                            length = Int(temple.y) - y
                        }

                        for ry in y..<y + length {
                            for rx in 0...settings.roadSize / 2 {
                                roads.insert(Pixel(x: x + rx, y: ry))
                                if rx > 0 {
                                    roads.insert(Pixel(x: x - rx, y: ry))
                                }
                            }
                        }

                        y += length

                        for ry in 0...settings.roadSize / 2 {
                            for rx in 0...settings.roadSize / 2 {
                                if pow(Decimal(rx), 2) + pow(Decimal(ry), 2) > pow(Decimal(settings.roadSize) / 2, 2) {
                                    continue
                                }

                                roads.insert(Pixel(x: x + rx, y: y + ry))
                                if rx > 0 {
                                    roads.insert(Pixel(x: x - rx, y: y + ry))
                                }
                            }
                        }
                    } else if y > Int(temple.y) {
                        let length: Int
                        if y - Int(temple.y) >= settings.roadSize && x != Int(temple.x) {
                            length = Int.random(in: settings.roadSize...min(settings.maxRoadLengthY, y - Int(temple.y)))
                        } else {
                            length = y - Int(temple.y)
                        }

                        for ry in y - length + 1...y {
                            for rx in 0...settings.roadSize / 2 {
                                roads.insert(Pixel(x: x + rx, y: ry))
                                if rx > 0 {
                                    roads.insert(Pixel(x: x - rx, y: ry))
                                }
                            }
                        }

                        y -= length

                        for ry in 0...settings.roadSize / 2 {
                            for rx in 0...settings.roadSize / 2 {
                                if pow(Decimal(rx), 2) + pow(Decimal(ry), 2) > pow(Decimal(settings.roadSize) / 2, 2) {
                                    continue
                                }

                                roads.insert(Pixel(x: x + rx, y: y - ry))
                                if rx > 0 {
                                    roads.insert(Pixel(x: x - rx, y: y - ry))
                                }
                            }
                        }
                    }
                }
                horizontal = !horizontal
            }
        }

        return roads
    }

    static func generateBushes(withSettings settings: GeneratorSettings, andEntities entities: [Entity], andRoads roads: Set<Pixel>) -> [BushEntity] {
        var bushes: [BushEntity] = []

        var x = settings.bushSpacingX
        while x + settings.bushSpacingX <= settings.width {
            var y = settings.bushSpacingY
            while y + settings.bushSpacingY <= settings.height {
                for _ in 1...3 {
                    let rx = Int.random(in: 0..<settings.bushFuzzinessX)
                    let ry = Int.random(in: 0..<settings.bushFuzzinessY)
                    let bush = BushEntity(sprite: settings.bush, x: Double(x + rx), y: Double(y + ry))
                    if !Level.isNearRoad(at: Pixel(x: x + rx, y: y + ry), withSettings: settings, andRoads: roads) {
                        continue
                    }
                    if !Level.isValidPosition(for: bush, andEntities: entities + bushes, andRoads: roads) {
                        continue
                    }
                    bushes.append(bush)
                    break
                }
                y += settings.bushSpacingY
            }
            x += settings.bushSpacingX
        }

        return bushes
    }

    static func generateTrees(withSettings settings: GeneratorSettings, andEntities entities: [Entity], andRoads roads: Set<Pixel>) -> [Entity] {
        var trees: [Entity] = []

        var x = settings.treeSpacingX
        while x + settings.treeSpacingX <= settings.width {
            var y = settings.treeSpacingY
            while y + settings.treeSpacingY <= settings.height {
                for _ in 1...3 {
                    let rx = Int.random(in: 0..<settings.treeFuzzinessX)
                    let ry = Int.random(in: 0..<settings.treeFuzzinessY)
                    let tree = Entity(sprite: settings.tree, x: Double(x + rx), y: Double(y + ry))
                    if !Level.isValidPosition(for: tree, andEntities: entities + trees, andRoads: roads) {
                        continue
                    }
                    trees.append(tree)
                    break
                }
                y += settings.treeSpacingY
            }
            x += settings.treeSpacingX
        }

        return trees
    }

    static func isNearRoad(at pixel: Pixel, withSettings settings: GeneratorSettings, andRoads roads: Set<Pixel>) -> Bool {
        var i = 0
        while i <= settings.bushOffroadDistance {
            if roads.contains(Pixel(x: pixel.x + i, y: pixel.y)) {
                return true
            } else if roads.contains(Pixel(x: pixel.x, y: pixel.y + i)) {
                return true
            } else if i > 0 {
                if roads.contains(Pixel(x: pixel.x - i, y: pixel.y)) {
                    return true
                } else if roads.contains(Pixel(x: pixel.x, y: pixel.y + i)) {
                    return true
                }
            }

            if i == settings.bushOffroadDistance {
                break
            } else if i <= settings.bushOffroadDistance - settings.roadSize {
                i += settings.roadSize
            } else {
                i = settings.bushOffroadDistance
            }
        }
        return true
    }

    static func isValidPosition(for entity: Entity, andEntities entities: [Entity], andRoads roads: Set<Pixel>) -> Bool {
        let minX = Int(entity.x) + entity.sprite.getMinX()
        let maxX = Int(entity.x) + entity.sprite.getMaxX() + 1
        let minY = Int(entity.y) + entity.sprite.getMinY()
        let maxY = Int(entity.y) + entity.sprite.getMaxY() + 1

        let entities = entities.filter { (otherEntity) -> Bool in
            if maxX < Int(otherEntity.x) + otherEntity.sprite.getMinX() {
                return false
            }
            if minX > Int(otherEntity.x) + otherEntity.sprite.getMaxX() + 1 {
                return false
            }
            if maxY < Int(otherEntity.y) + otherEntity.sprite.getMinY() {
                return false
            }
            if minY > Int(otherEntity.y) + otherEntity.sprite.getMaxY() + 1 {
                return false
            }

            return true
        }

        for pixel in entity.getHitBox() {
            if roads.contains(pixel) {
                return false
            }

            for otherEntity in entities {
                if otherEntity.sprite.isHitBox(x: pixel.x - Int(otherEntity.x), y: pixel.y - Int(otherEntity.y), threshold: 0.5) {
                    return false
                }
            }
        }

        return true
    }

    static func generate(withSettings settings: GeneratorSettings) -> Level {
        var entities: [Entity] = []

        let temples = Level.generateTemples(withSettings: settings)
        entities.append(contentsOf: temples)

        let roads = Level.generateRoads(withSettings: settings, andTemples: temples)

        let bushes = Level.generateBushes(withSettings: settings, andEntities: entities, andRoads: roads)
        entities.append(contentsOf: bushes)

        let trees = Level.generateTrees(withSettings: settings, andEntities: entities, andRoads: roads)
        entities.append(contentsOf: trees)

//        let combinedTreesSprite = CombinedSprite(sprites: [])
//        for tree in trees {
//            combinedTreesSprite.add(sprite: tree.sprite, at: Pixel(x: Int(tree.x), y: Int(tree.y)))
//        }
//        let combinedTrees = Entity(sprite: combinedTreesSprite, x: 0, y: 0)
//        entities.append(combinedTrees)

//        entities.append(Entity(sprite: DebugRoadSprite(name: "DebugRoadSprite", pixels: roads), x: 0, y: 0))

        return Level(background: settings.background, character: settings.character, spawnX: settings.spawnX, spawnY: settings.spawnY, width: settings.width, height: settings.height, entities: entities)
    }

}

class DebugRoadSprite: Sprite {

    let roadPixels: Set<Pixel>

    init(name: String, pixels: Set<Pixel>) {
        self.roadPixels = pixels

        super.init(name: name, pixels: [], anchorX: 0, anchorY: 0)
    }

    override func getWidth() -> Int {
        var minX = 0, maxX = 0
        for pixel in self.roadPixels {
            minX = min(pixel.x, minX)
            maxX = max(pixel.x, maxX)
        }
        return maxX - minX
    }

    override func getHeight() -> Int {
        var minY = 0, maxY = 0
        for pixel in self.roadPixels {
            minY = min(pixel.y, minY)
            maxY = max(pixel.y, maxY)
        }
        return maxY - minY
    }

    override func getMinX() -> Int {
        var minX = 0
        for pixel in self.roadPixels {
            minX = min(pixel.x, minX)
        }
        return minX
    }

    override func getMinY() -> Int {
        var minY = 0
        for pixel in self.roadPixels {
            minY = min(pixel.y, minY)
        }
        return minY
    }

    override func getMaxX() -> Int {
        var maxX = 0
        for pixel in self.roadPixels {
            maxX = max(pixel.x, maxX)
        }
        return maxX
    }

    override func getMaxY() -> Int {
        var maxY = 0
        for pixel in self.roadPixels {
            maxY = max(pixel.y, maxY)
        }
        return maxY
    }

    override func getColor(x: Int, y: Int) -> CGColor {
        return self.roadPixels.contains(Pixel(x: x + self.anchorX, y: y + self.anchorY)) ? CGColor(red: 1, green: 0, blue: 0, alpha: 0.5) : .clear
    }

    override func isHitBox(x: Int, y: Int, threshold: Double) -> Bool {
        return false
    }

    override func getHitBox(threshold: Double = 0.5) -> Set<Pixel> {
        return []
    }

}

struct GeneratorSettings {

    let background: Sprite = Sprite.load(name: "background") ?? Sprite.EMPTY
    let character: Sprite = Sprite.load(name: "character") ?? Sprite.EMPTY
    let temple: Sprite = Sprite.load(name: "temple") ?? Sprite.EMPTY
    let bush: Sprite = Sprite.load(name: "bush") ?? Sprite.EMPTY
    let tree: Sprite = Sprite.load(name: "tree1") ?? Sprite.EMPTY

    let width: Int = 360 + (360 - 14) * 3
    let height: Int = 225 + (225 - 18) * 3

    let spawnX: Double = (360 - 14) * 2 + 180
    let spawnY: Double = (225 - 18) * 2 + 112

    let templeCount: Int = 5
    let templeSpacing: Int = 0
    let templePaddingX: Double = 32
    let templePaddingY: Double = 32

    let roadSize: Int = 32
    let maxRoadLengthX: Int = 256
    let maxRoadLengthY: Int = 128

    let bushOffroadDistance: Int = 32
    let bushSpacingX: Int = 128
    let bushSpacingY: Int = 128
    let bushFuzzinessX: Int = 64
    let bushFuzzinessY: Int = 64

    let treeSpacingX: Int = 40
    let treeSpacingY: Int = 64
    let treeFuzzinessX: Int = 40
    let treeFuzzinessY: Int = 64

}

