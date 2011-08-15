//
//  MBTUtils.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTUtils : NSObject
+ (NSRect) getStatusItemFrame:(NSStatusItem*)statusItem;
+ (NSPoint) determinePopUpPosition:(NSSize)size statusItem:(NSRect)statusItem;
@end
