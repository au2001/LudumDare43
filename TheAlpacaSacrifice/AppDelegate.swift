//
//  AppDelegate.swift
//  TheAlpacaSacrifice
//
//  Created by Aurélien on 01/12/2018.
//  Copyright © 2018 TheAlpacaSacrifice. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let view = ContentView()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application

        let options: [NSApplication.PresentationOptions] = [.hideDock, .hideMenuBar, .disableAppleMenu, .disableProcessSwitching, .disableHideApplication, .disableMenuBarTransparency, .fullScreen, .disableCursorLocationAssistance]
        self.view.enterFullScreenMode(NSScreen.main!, withOptions: [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: options])

        _ = Sprite.loadAll()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }

}

