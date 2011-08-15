//
//  MBTUtils.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTUtils.h"
#import <AppKit/AppKit.h>

@interface NSStatusItem (Hack)
- (NSWindow*)windowHack;
@end
@implementation NSStatusItem (Hack)
- (NSWindow*)windowHack {
    return [self valueForKeyPath:@"_fWindow"];
}
@end

@implementation MBTUtils

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSRect) getStatusItemFrame:(NSStatusItem*)statusItem {
    return [[statusItem windowHack] frame];
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

@end
