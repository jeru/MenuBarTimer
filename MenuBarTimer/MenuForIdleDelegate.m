//
//  MyStatusMenuDelegate.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MenuForIdleDelegate.h"

@implementation MyStatusMenuDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)menuWillOpen:(NSMenu *)menu {
    NSTimer* timer = [NSTimer timerWithTimeInterval:0.15
                            target:self
                            selector:@selector(focusingTimerFire:)
                            userInfo:nil
                            repeats:YES];
    focusingTimer = timer;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
}

- (void)focusingTimerFire:(NSTimer*)theTimer {
    NSTimer* timer = focusingTimer;
    focusingTimer = nil;
    [timer invalidate];
    [[durationInput window] makeFirstResponder:durationInput];
}

@end
