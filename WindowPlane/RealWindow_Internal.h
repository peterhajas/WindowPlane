//
//  RealWindow_Internal.h
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

#import "RealWindow.h"

@interface RealWindow()

@property (nonatomic, nullable, strong) NSImage *contents;
@property (nonatomic) CGWindowID windowID;
@property (nonatomic) CGRect bounds;
@property (nonatomic, nullable, copy) NSString *windowTitle;
@property (nonatomic, nullable, copy) NSString *appName;

@end
