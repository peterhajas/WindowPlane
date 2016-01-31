//
//  View.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

import AppKit

class View : NSView {
    required init?(coder: NSCoder) {
        fatalError("Use init by passing a frame instead")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        
        self.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        
        self.wantsLayer = true
    }
    
    override var flipped: Bool {
        get {
            return true
        }
    }
    
    override var description: String {
        get {
            let x = self.frame.origin.x
            let y = self.frame.origin.y
            let w = self.frame.size.width
            let h = self.frame.size.height
            
            let frameDescription = "(\(x), \(y)) - \(w) x \(h)"
            let classDescription = self.className
            
            return classDescription + " " + frameDescription
        }
    }
}
