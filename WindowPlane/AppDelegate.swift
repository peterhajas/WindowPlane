//
//  AppDelegate.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let windowObserver = WindowObserver()
    let windowHostingView = WindowHostingView(frame: CGRectMake(0,0,500,500))

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        window.contentView = windowHostingView
        windowObserver.delegate = windowHostingView
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

