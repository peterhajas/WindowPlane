//
//  RealWindow.h
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RealWindow;

@protocol RealWindowDelegate

- (void)realWindowDidAppear:(RealWindow *)window;
- (void)realWindowDidDisappear:(RealWindow *)window;
- (void)realWindowContentsChanged:(RealWindow *)window;

@end

@interface RealWindowTracker : NSObject

+ (instancetype)sharedWindowTracker;

@property (nonatomic, nullable, weak) id<RealWindowDelegate> delegate;

@end

@interface RealWindow : NSObject

@property (nonatomic, nullable, readonly, strong) NSImage *contents;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, nullable, readonly, copy) NSString *windowTitle;
@property (nonatomic, nullable, readonly, copy) NSString *appName;

@end

NS_ASSUME_NONNULL_END
