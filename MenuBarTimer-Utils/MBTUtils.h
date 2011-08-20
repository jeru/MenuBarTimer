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

@end

@interface MBTUtils (Time)

+ (NSString*) renderTime:(double)seconds;

// return value: the number of seconds.
// return negative number for error.
+ (int)parseTimeString:(NSString*)text;

@end

@interface MBTUtils (LoginItems)

// returns YES if found.
+ (BOOL)checkLoginItem:(NSString*)appPath;

// returns YES if successfully removed.
+ (BOOL)removeLoginItem:(NSString*)appPath;

// returns YES if successfully added.
+ (BOOL)addLoginItem:(NSString*)appPath;

@end
