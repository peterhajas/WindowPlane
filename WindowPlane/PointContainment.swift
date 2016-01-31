//
//  PointContainment.swift
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    mutating func constrainToRect(rect: CGRect) {
        let size = rect.size
        var x = rect.origin.x
        var y = rect.origin.y
        x = min(x, size.width)
        x = max(x, 0)
        y = min(y, size.height)
        y = max(y, 0)
        
        self.x = x
        self.y = y
    }
}
