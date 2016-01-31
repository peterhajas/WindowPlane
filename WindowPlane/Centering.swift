//
//  Centering.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

import CoreGraphics
import AppKit

protocol Centerable {
    var center: CGPoint { get set }
}

extension CGRect: Centerable {
    var center: CGPoint {
        get {
            let x = self.origin.x + (self.size.width / 2)
            let y = self.origin.y + (self.size.height / 2)
            
            return CGPointMake(x, y)
        }
        set(center) {
            let x = center.x - (self.size.width / 2)
            let y = center.y - (self.size.height / 2)
            
            self.origin = CGPointMake(x, y)
        }
    }
}

extension NSView: Centerable {
    var center: CGPoint {
        get {
            return self.frame.center
        }
        set(center) {
            var frame = self.frame
            frame.center = center
            self.frame = frame
        }
    }
}
