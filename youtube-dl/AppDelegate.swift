//
//  AppDelegate.swift
//  youtube-dl
//
//  Created by Ivan Dikic on 01/06/15.
//  Copyright (c) 2015 Futurice. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let mainWindowController: MainWindowController = MainWindowController(windowNibName: "MainWindowController")

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // Insert code here to initialize your application
        mainWindowController.showWindow(self)

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

