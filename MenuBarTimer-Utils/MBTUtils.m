//
//  MBTUtils.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTUtils.h"
#import <AppKit/AppKit.h>

//////////////
// MBTUtils //
//////////////

@implementation MBTUtils

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

/////////////////////////////
// Some utility functions. //
/////////////////////////////

static inline BOOL isBlank(unichar c) {
    return c == ' ' || c == '\t' || c == '\v' || c == '\n' || c == '\r';
}

static inline BOOL isDigit(unichar c) {
    return '0' <= c && c <= '9';
}

enum MBTTimerSuffix {
    MBTTimerSuffixNone = 0,
    MBTTimerSuffixSecond,
    MBTTimerSuffixMinute,
    MBTTimerSuffixHour,
    MBTTimerSuffixDay
};

static inline BOOL regexFound(NSRegularExpression *re, NSString *str) {
    return [re
            numberOfMatchesInString:str
            options:0
            range:NSMakeRange(0, [str length])] > 0;
}

static inline enum MBTTimerSuffix getSuffix(unichar c) {
    if ('A' <= c && c <= 'Z')
        c = c - 'A' + 'a';
    NSString *second =
        NSLocalizedString(@"secondUnit", 
                          @"Short input unit for second. "
                           "It can be a comma-separated set of letters.");
    NSString *minute =
        NSLocalizedString(@"minuteUnit", 
                          @"Short input unit for minute. "
                          "It can be a comma-separated set of letters.");
    NSString *hour =
        NSLocalizedString(@"hourUnit", 
                          @"Short input unit for hour. "
                          "It can be a comma-separated set of letters.");
    NSString *day =
        NSLocalizedString(@"dayUnit", 
                          @"Short input unit for day. "
                          "It can be a comma-separated set of letters.");
    NSError *error = nil;
    NSRegularExpression *regex =
        [NSRegularExpression
         regularExpressionWithPattern:[NSString
                                       stringWithFormat:
                                       @"(^|,)%C($|,)", c]
         options:NSRegularExpressionCaseInsensitive error:&error];
    assert(error == nil);
    if (regexFound(regex, second)) return MBTTimerSuffixSecond;
    if (regexFound(regex, minute)) return MBTTimerSuffixMinute;
    if (regexFound(regex, hour  )) return MBTTimerSuffixHour;
    if (regexFound(regex, day   )) return MBTTimerSuffixDay;
    return MBTTimerSuffixNone;
}

/////////////////////
// MBTUtils (Time) //
/////////////////////

@implementation MBTUtils (Time)

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
        if (!isBlank(c) && !isDigit(c)
            && getSuffix(c) == MBTTimerSuffixNone)
        {
            return -1;
        }
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
        enum MBTTimerSuffix suf = MBTTimerSuffixSecond;
        if (j < [text length]) {
            suf = getSuffix([text characterAtIndex:j]);
            ++j;
        }
        if (suf == MBTTimerSuffixSecond) {
            if (second != -1) return -3;
            second = num;
        } else if (suf == MBTTimerSuffixMinute) {
            if (minute != -1) return -3;
            minute = num;
        } else if (suf == MBTTimerSuffixHour) {
            if (hour != -1) return -3;
            hour = num;
        } else {  // suf == MBTTimerSuffixDay
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

#import <Cocoa/Cocoa.h>

/////////////////////////////
// Some utility functions. //
/////////////////////////////

static LSSharedFileListRef getList() {
    return LSSharedFileListCreate(NULL,
                                  kLSSharedFileListSessionLoginItems,
                                  NULL);
}

static BOOL equivPath(NSString *a, NSString *b) {
    if (a == nil || b == nil) return a == nil && b == nil;
    return [a isEqualToString:b];
}

static BOOL findItem(LSSharedFileListRef list,
                     NSString* appPath,
                     void (*action)(LSSharedFileListRef,
                                    LSSharedFileListItemRef))
{
    BOOL ret = NO;
    UInt32 seed;
    CFArrayRef array = LSSharedFileListCopySnapshot(list, &seed);
    for (id enum_item in (NSArray*)array) {
        LSSharedFileListItemRef item =
        (LSSharedFileListItemRef)enum_item;
        CFURLRef url;
        OSStatus retval = LSSharedFileListItemResolve(item, 0,
                                                      &url, NULL);
        NSString *pathStr = [(NSURL*)url path];
        if (retval == noErr && equivPath(pathStr, appPath)) {
            ret = YES;
            if (action) action(list, item);
        }
        CFRelease(url);
        
        if (ret) break;
    }
    CFRelease(array);
    return ret;
}

static void deleteSharedFileListItem(LSSharedFileListRef list,
                                     LSSharedFileListItemRef item) {
    LSSharedFileListItemRemove(list, item);
}

///////////////////////////
// MBTUtils (LoginItems) //
///////////////////////////

@implementation MBTUtils (LoginItems)

+ (BOOL)checkLoginItem:(NSString*)appPath {
    LSSharedFileListRef list = getList();
    if (!list) return NO;
    BOOL ret = findItem(list, appPath, NULL);
    CFRelease(list);
    return ret;
}

+ (BOOL)removeLoginItem:(NSString*)appPath {
    NSLog(@"removeLoginItem(%@)", appPath);
    LSSharedFileListRef list = getList();
    if (!list) return NO;
    BOOL ret = findItem(list, appPath, deleteSharedFileListItem);
    CFRelease(list);
    return ret;
}

+ (BOOL)addLoginItem:(NSString*)appPath {
    NSLog(@"addLoginItem(%@)", appPath);
    LSSharedFileListRef list = getList();
    if (!list) return NO;
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListItemRef item =
    LSSharedFileListInsertItemURL(
                                  list, kLSSharedFileListItemLast,
                                  (CFStringRef)@"MenuBarTimer", NULL, url,
                                  NULL, NULL);
    BOOL ret = NO;
    if (item) {
        CFRelease(item);
        ret = YES;
    }
    CFRelease(list);
    return ret;
}

@end
