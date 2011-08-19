//
//  MBTUtils.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTUtils.h"
#import <AppKit/AppKit.h>

/////////////////////////////
// Some utility functions. //
/////////////////////////////

static inline BOOL isBlank(unichar c) {
    return c == ' ' || c == '\t' || c == '\v' || c == '\n' || c == '\r';
}

static inline BOOL isDigit(unichar c) {
    return '0' <= c && c <= '9';
}

static inline BOOL isSuffix(unichar c) {
    if ('A' <= c && c <= 'Z')
        c = c - 'A' + 'a';
    return c == 's' || c == 'm' || c == 'h' || c == 'd';
}

//////////////
// MBTUtils //
//////////////

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

+ (int)parseTimeString:(NSString*)text {
    int64_t second = -1, minute = -1, hour = -1, day = -1;
    for (NSUInteger i = 0; i < [text length]; ++i) {
        unichar c = [text characterAtIndex:i];
        if (!isBlank(c) && !isDigit(c) && !isSuffix(c)) return -1;
    }
    for (NSUInteger i = 0, j = 0; i < [text length]; i = j) {
        unichar c = [text characterAtIndex:i];
        if (isBlank(c)) {
            ++j;
            continue;
        }
        if (!isDigit(c))
            return -1;
        int64_t num = 0;
        for (; j < [text length]; ++j) {
            unichar c2 = [text characterAtIndex:j];
            if (!isDigit(c2))
                break;
            num = num * 10 + (c2 - '0');
            if (num > INT32_MAX)
                return -2;
        }
        unichar suf = 's';
        if (j < [text length] && isSuffix([text characterAtIndex:j])) {
            suf = [text characterAtIndex:j];
            ++j;
        }
        if (suf == 's') {
            if (second != -1) return -3;
            second = num;
        } else if (suf == 'm') {
            if (minute != -1) return -3;
            minute = num;
        } else if (suf == 'h') {
            if (hour != -1) return -3;
            hour = num;
        } else {  // suf == 'd'
            if (day != -1) return -3;
            day = num;
        }
    }
    if (second == -1 && minute == -1 && hour == -1 && day == -1)
        return -4;
    int64_t ret = 0;
    if (day != -1) ret += day;
    ret *= 24;
    if (hour != -1) ret += hour;
    ret *= 60;
    if (minute != -1) ret += minute;
    ret *= 60;
    if (second != -1) ret += second;
    if (ret > INT32_MAX)
        return -2;
    return (int)ret;
}

@end
