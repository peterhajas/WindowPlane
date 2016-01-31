//
//  WindowObserver.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

protocol WindowObserverDelegate {
    func updateWindowContents(window: RealWindow)
    func addWindow(window: RealWindow)
    func removeWindow(window: RealWindow)
}

class WindowObserver : NSObject, RealWindowDelegate {
    let windowTracker = RealWindowTracker.sharedWindowTracker()
    
    var delegate: WindowObserverDelegate?
    
    override init() {
        super.init()
        windowTracker.delegate = self
    }
    
    func realWindowContentsChanged(window: RealWindow) {
        delegate?.updateWindowContents(window)
    }
    
    func realWindowDidAppear(window: RealWindow) {
        delegate?.addWindow(window)
    }
    
    func realWindowDidDisappear(window: RealWindow) {
        delegate?.removeWindow(window)
    }
}
