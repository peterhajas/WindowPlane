//
//  WindowHostingView.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

import AppKit

class IdentityTransformPreferringLayer : CALayer {
    override var transform: CATransform3D {
        get {
            return super.transform
        }
        set(t) {
            super.transform = CATransform3DIdentity
        }
    }
}

class WindowHostingView : View, WindowObserverDelegate {
    var views: [RealWindow : WindowView] = [RealWindow : WindowView]()
    
    let scaleFactor: CGFloat = 0.2
    
    let windowMoveGesture: NSPanGestureRecognizer = NSPanGestureRecognizer()
    
    var currentMovedView: WindowView?
    var currentMovedViewStartCenter: CGPoint = CGPointZero
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        self.layer?.backgroundColor = NSColor.redColor().CGColor
        
        windowMoveGesture.target = self
        windowMoveGesture.action = Selector("windowMoveChanged")
        self.addGestureRecognizer(windowMoveGesture)
        self.layer?.masksToBounds = false
        self.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init by passing a frame instead")
    }
    
    func updateWindowContents(window: RealWindow) {
        if let view = views[window] {
            view.contents = window.contents
        }
        else {
            // This probably indicates a bug...
            addWindow(window)
            updateWindowContents(window)
        }
    }
    
    override func makeBackingLayer() -> CALayer {
        return IdentityTransformPreferringLayer()
    }
    
    func addWindow(window: RealWindow) {
        let view = WindowView()
        view.title = window.windowTitle
        view.appName = window.appName
        views[window] = view
        self.addSubview(view)
        
        bounds = window.bounds
        let x = bounds.origin.x * scaleFactor + 300
        let y = bounds.origin.y * scaleFactor + 300
        
        let width = bounds.size.width * scaleFactor
        let height = bounds.size.height * scaleFactor
        
        let frame = CGRectMake(x, y, width, height)
        
        view.frame = frame
    }
    
    func removeWindow(window: RealWindow) {
        let view = views[window]
        view?.removeFromSuperview()
        views.removeValueForKey(window)
    }
    
    func windowMoveChanged() {
        let location = windowMoveGesture.locationInView(self)
        let hitView: NSView? = self.hitTest(location)
        let translation = windowMoveGesture.translationInView(self)
        
        switch windowMoveGesture.state {
        case .Began:
            windowMoveGesture.setTranslation(CGPointZero, inView: self)
            
            if let view = hitView as? WindowView {
                currentMovedView = view
                currentMovedViewStartCenter = view.center
            }
        case .Changed:
            if let view = currentMovedView {
                var viewNewCenter = CGPointMake(currentMovedViewStartCenter.x + translation.x,
                                                currentMovedViewStartCenter.y + translation.y)
                
                viewNewCenter.constrainToRect(self.bounds)
                view.center = viewNewCenter
            }
        default:
            currentMovedView = nil
        }
    }
}
