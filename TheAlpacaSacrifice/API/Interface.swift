//
//  Interface.swift
//  TheAlpacaSacrifice
//
//  Created by Aurélien on 03/12/2018.
//  Copyright © 2018 TheAlpacaSacrifice. All rights reserved.
//

import Cocoa

protocol Interface {

    init(contentView: ContentView)

    func keyPress(event: NSEvent)
    func keyDown(event: NSEvent)
    func keyUp(event: NSEvent)

    func mouseMoved(event: NSEvent)
    func mouseDown(event: NSEvent)
    func mouseUp(event: NSEvent)

    func paint()

}

