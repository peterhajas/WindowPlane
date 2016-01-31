//
//  WindowView.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

import AppKit

class WindowView : View {
    let imageView: NSImageView
    let drawBorders: Bool = true
    var title: String? = nil
    var appName: String? = nil
    
    var contents: NSImage? {
        get {
            return imageView.image
        }
        set(value) {
            if let image = value {
                imageView.image = image
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        imageView = NSImageView(frame: frameRect)
        imageView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        
        super.init(frame:frameRect)
        
        self.autoresizingMask = [.ViewNotSizable]
        
        self.addSubview(imageView)
        
        if drawBorders {
            let borderColor = NSColor.orangeColor().CGColor
            let borderWidth: CGFloat = 10.0
            let layer = self.layer!
            
            layer.borderColor = borderColor
            layer.borderWidth = borderWidth
        }
    }
    
    override func hitTest(aPoint: NSPoint) -> NSView? {
        if ((self.layer?.containsPoint(aPoint)) != nil) {
            return self
        }
        else {
            return nil
        }
    }
    
    var appNameDescription: String {
        if let appName = appName {
            return appName
        }
        else {
            return "UnknownApp"
        }
    }
    
    var titleDescription: String {
        if let title = title {
            return title
        }
        else {
            return "UnknownWindowTitle"
        }
    }
    
    override var description: String {
        get {
            return "\(super.description) - \(appNameDescription): \(titleDescription)"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init by passing a frame instead")
    }
}
