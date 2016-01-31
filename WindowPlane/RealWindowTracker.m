//
//  RealWindowTracker.m
//  WindowPlane
//
//  Created by Peter Hajas on 1/31/16.
//  Copyright © 2016 Peter Hajas. All rights reserved.
//

#import "RealWindow_Internal.h"
#import <CoreVideo/CVDisplayLink.h>

#define kWindowTimerUpdateIntervalSeconds (1)

@interface RealWindowTracker()

@property (nonatomic, retain) NSMutableArray *visibleRealWindows;

@property (nonatomic) CVDisplayLinkRef displayLink;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation RealWindowTracker

+ (instancetype)sharedWindowTracker {
    static RealWindowTracker *sharedWindowTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWindowTracker = [[RealWindowTracker alloc] init];
    });
    
    return sharedWindowTracker;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _visibleRealWindows = [NSMutableArray new];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kWindowTimerUpdateIntervalSeconds target:self selector:@selector(_updateFromTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:[self timer] forMode:NSRunLoopCommonModes];
    }
    
    return self;
}

- (void)setDelegate:(id<RealWindowDelegate>)delegate {
    _delegate = delegate;
    
    for (RealWindow *window in [self visibleRealWindows]) {
        [[self delegate] realWindowDidAppear:window];
    }
    
    [self _updateWindows];
}

- (void)_updateFromTimer {
    [self _updateWindows];
}

- (NSArray *)_lastKnownWindowIDs {
    NSMutableArray *lastKnownIDs = [NSMutableArray array];
    
    for (RealWindow *window in [self visibleRealWindows]) {
        [lastKnownIDs addObject:@([window windowID])];
    }
    
    return lastKnownIDs;
}

- (RealWindow *)_realWindowForWindowID:(CGWindowID)windowID {
    for (RealWindow *window in [self visibleRealWindows]) {
        if ([window windowID] == windowID) {
            return window;
        }
    }
    return nil;
}

- (NSDictionary *)_windowInfoForWindowID:(CGWindowID)windowID {
    CFArrayRef windowInfos = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow, windowID);
    
    NSDictionary *windowInfo = nil;
    
    if (CFArrayGetCount(windowInfos) > 0) {
        windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowInfos, 0);
        windowInfo = [windowInfo copy];
        CFRelease(windowInfos);
    }
    
    return windowInfo;
}

- (CGRect)_boundsForWindowInfo:(NSDictionary *)windowInfo {
    NSDictionary *boundsDict = [windowInfo objectForKey:(NSString *)kCGWindowBounds];
    CGRect bounds;
    
    bounds.origin.x = [[boundsDict objectForKey:@"X"] floatValue];
    bounds.origin.y = [[boundsDict objectForKey:@"Y"] floatValue];
    bounds.size.width = [[boundsDict objectForKey:@"Width"] floatValue];
    bounds.size.height = [[boundsDict objectForKey:@"Height"] floatValue];
    
    return bounds;
}

- (NSString *)_windowNameForWindowInfo:(NSDictionary *)windowInfo {
    NSString *windowName = [windowInfo objectForKey:(NSString *)kCGWindowName];
    return windowName;
}

- (NSString *)_appNameForWindowInfo:(NSDictionary *)windowInfo {
    NSString *appName = [windowInfo objectForKey:(NSString *)kCGWindowOwnerName];
    return appName;
}

- (void)_updateWindows {
    CGWindowListOption options = kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements;
    CFArrayRef windows = CGWindowListCreate(options, kCGNullWindowID);
    
    NSInteger count = CFArrayGetCount(windows);
    
    NSMutableArray *windowIDs = [NSMutableArray new];
    
    for (NSInteger i = 0; i < count; i++) {
        CGWindowID windowID = (CGWindowID)CFArrayGetValueAtIndex(windows, i);
        
        [windowIDs addObject:@(windowID)];
    }
    
    [self _updateForOnscreenWindowIDs:windowIDs];
    
    CFRelease(windows);
}

#define kAddedWindowsKey @"Added"
#define kRemovedWindowsKey @"Removed"

- (NSDictionary *)_differencesBetweenLastKnownWindowIDs:(NSArray *)lastKnownIDs andNewWindowIDs:(NSArray *)newIDs {
    NSMutableDictionary *differences = [NSMutableDictionary dictionary];
    NSMutableArray *added = [NSMutableArray array];
    NSMutableArray *removed = [NSMutableArray array];
    
    for (NSNumber *windowID in newIDs) {
        if (![lastKnownIDs containsObject:windowID]) {
            [added addObject:windowID];
        }
    }
    
    for (NSNumber *windowID in lastKnownIDs) {
        if (![newIDs containsObject:windowID]) {
            [removed addObject:windowID];
        }
    }
    
    [differences setObject:added forKey:kAddedWindowsKey];
    [differences setObject:removed forKey:kRemovedWindowsKey];
    
    return differences;
}

- (void)_updateForOnscreenWindowIDs:(NSArray *)onscreenWindowIDs {
    NSDictionary *differences = [self _differencesBetweenLastKnownWindowIDs:[self _lastKnownWindowIDs]
                                                            andNewWindowIDs:onscreenWindowIDs];
    
    [self _updateForAddedWindows:[differences objectForKey:kAddedWindowsKey]];
    [self _updateForRemovedWindows:[differences objectForKey:kRemovedWindowsKey]];
    
    for (NSNumber *windowIDNumber in onscreenWindowIDs) {
        [self _updateContentsOfWindowWithID:[windowIDNumber unsignedIntValue]];
    }
}

- (void)_updateForAddedWindows:(NSArray *)added {
    for (NSNumber *windowIDNumber in added) {
        CGWindowID windowID = [windowIDNumber unsignedIntValue];
        
        RealWindow *window = [[RealWindow alloc] init];
        NSDictionary *info = [self _windowInfoForWindowID:windowID];
        
        [window setWindowID:windowID];
        [window setBounds:[self _boundsForWindowInfo:info]];
        [window setWindowTitle:[self _windowNameForWindowInfo:info]];
        [window setAppName:[self _appNameForWindowInfo:info]];
        
        [[self visibleRealWindows] addObject:window];
        
        [[self delegate] realWindowDidAppear:window];
    }
}

- (void)_updateForRemovedWindows:(NSArray *)removed {
    for (NSNumber *windowIDNumber in removed) {
        CGWindowID windowID = [windowIDNumber unsignedIntValue];
        
        RealWindow *window = [self _realWindowForWindowID:windowID];
        
        if (window) {
            [[self visibleRealWindows] removeObject:window];
            
            [[self delegate] realWindowDidDisappear:window];
        }
    }
}

- (void)_updateContentsOfWindowWithID:(CGWindowID)windowID {
    CGRect screenBounds = CGRectNull;
    CGWindowListOption createImageListOptions = kCGWindowListOptionIncludingWindow;
    CGWindowImageOption createImageImageOptions = kCGWindowImageBoundsIgnoreFraming;
    
    CGImageRef cgImage = CGWindowListCreateImage(screenBounds, createImageListOptions, windowID, createImageImageOptions);
    CGFloat width = CGImageGetWidth(cgImage);
    CGFloat height = CGImageGetHeight(cgImage);
    
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:CGSizeMake(width, height)];
    
    CGImageRelease(cgImage);
    
    RealWindow *window = [self _realWindowForWindowID:windowID];
    
    [window setContents:image];
    
    [[self delegate] realWindowContentsChanged:window];
}

@end
