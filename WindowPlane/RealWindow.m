//
//  RealWindow.m
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

#import "RealWindow_Internal.h"

@implementation RealWindow

- (NSString *)description {
    NSString *description = [super description];
    
    description = [description stringByAppendingString:@" "];
    description = [description stringByAppendingString:[self appName]];
    description = [description stringByAppendingString:@" "];
    description = [description stringByAppendingString:[self windowTitle]];
    
    return description;
}

@end
