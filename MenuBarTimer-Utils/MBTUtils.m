//
//  MBTUtils.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTUtils.h"
#import <AppKit/AppKit.h>

@implementation MBTUtils

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSPoint) determinePopUpPosition:(NSSize)size statusItem:(NSRect)statusItem {
    NSSize screen = [[NSScreen mainScreen] frame].size;
    NSPoint ret;
    ret.y = statusItem.origin.y - size.height;
    if (size.width > screen.width) {
        ret.x = 0;
    } else if (statusItem.origin.x + size.width <= screen.width) {
        ret.x = statusItem.origin.x;
    } else if (statusItem.origin.x + statusItem.size.width >= size.width) {
        ret.x = statusItem.origin.x + statusItem.size.width - size.width;
    } else {
        // TODO: any better way to determine the position?
        ret.x = 0;
    }
    return ret;
}

+ (NSString*)renderTime:(double)seconds {
    if (seconds < 0.5 - 1e-6) {
        return @"00:00";
    } else {
        int intSeconds = (int)floor(seconds + 0.5);
        if (intSeconds >= 15 * 60)
            intSeconds /= 60;
        return [NSString stringWithFormat:@"%.2d:%.2d", intSeconds / 60, intSeconds % 60];
    }
}

@end
