//
//  MBTUtils.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTUtils : NSObject

+ (NSPoint) determinePopUpPosition:(NSSize)size statusItem:(NSRect)statusItem;

+ (NSString*) renderTime:(double)seconds;

// return value: the number of seconds.
// return negative number for error.
+ (int)parseTimeString:(NSString*)text;

@end
