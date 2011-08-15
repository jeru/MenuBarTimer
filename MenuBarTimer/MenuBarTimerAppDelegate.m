//
//  MenuBarTimerAppDelegate.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MenuBarTimerAppDelegate.h"
#import "MBTUtils.h"

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

// return value: the number of seconds.
// return negative number for error.
static int parseTimeString(NSString* text) {
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

static void AutomatonPanic(NSString* msg) {
    NSLog(@"AutomanonPanic: %@", msg);
    for (;;);
}

/////////////////////////////
// MenuBarTimerAppDelegate //
/////////////////////////////

@interface MenuBarTimerAppDelegate () {
    NSTimer *timingTimer;
    double timingSeconds;
}
- (void)renderSeconds:(double)seconds;
- (void)timingTick;

- (void)setUpForStateIdle;
- (void)setUpForStateTiming:(double)seconds;
- (void)setUpForStatePaused;
- (void)setUpForStateFinished;
@end

@implementation MenuBarTimerAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)awakeFromNib {
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setHighlightMode:YES];
    [statusItem setAction:@selector(openStatusItem:)];
    [self setUpForStateIdle];
}

- (IBAction)openStatusItem:(id)sender {
    if (state == MBTS_IDLE) {
        if ([windowForInput isVisible]) {
            [self clickCancel:sender];
        } else {
            NSRect r = [MBTUtils getStatusItemFrame:statusItem];
            NSPoint p = [MBTUtils determinePopUpPosition:[windowForInput frame].size
                                              statusItem:r];
            [windowForInput setFrameOrigin:p];
            [windowForInput setMovable:NO];
            [windowForInput makeKeyAndOrderFront:sender];
            [durationInput selectText:self];
        }
    } else if (state == MBTS_TIMING || state == MBTS_PAUSED) {
        [statusItem popUpStatusItemMenu:menuForStateTimingOrPaused];
    }
}

// TODO: Currently, the text field is cleared to avoid errors again (eg., when you close the menu).
//       Find a better way to distinguish the "Action" of text field when an Enter is typed and when
//       the menu is closed.
- (IBAction)clickGo:(id)sender {
    if (state != MBTS_IDLE) AutomatonPanic(@"Expect state = MBTS_IDLE");
    NSString *text = [durationInput stringValue];
    int time = parseTimeString(text);
    if (time < 0) {
        NSAlert *theAlert = [NSAlert
                             alertWithMessageText:@"Something wrong"
                             defaultButton:@"OK"
                             alternateButton:nil
                             otherButton:nil
                             informativeTextWithFormat:@"Don't know what the time string means: %s.", text];
        [durationInput setStringValue:@""];
        [theAlert runModal];
    } else {
        [windowForInput orderOut:sender];
        [self setUpForStateTiming:time];
    }
}

- (IBAction)clickCancel:(id)sender {
    [windowForInput orderOut:sender];
}

- (IBAction)clickPauseOrContinue:(id)sender {
    if (state == MBTS_TIMING) {
        // The action is "pause".
        [menuForStateTimingOrPaused cancelTracking];
        [self setUpForStatePaused];
    } else if (state == MBTS_PAUSED) {
        // The action is "continue".
        [menuForStateTimingOrPaused cancelTracking];
        [self setUpForStateTiming:timingSeconds];
    } else {
        AutomatonPanic(@"Expect state = MBTS_TIMING or MBTS_PAUSED");
    }
}

- (IBAction)clickStop:(id)sender {
    if (state != MBTS_TIMING && state != MBTS_PAUSED)
        AutomatonPanic(@"Expect state = MBTS_TIMING or MBTS_PAUSED");
    if (state == MBTS_TIMING) {
        [timingTimer invalidate];
        timingTimer = nil;
    }
    [menuForStateTimingOrPaused cancelTracking];
    [self setUpForStateIdle];
}

- (void)renderSeconds:(double)seconds {
    if (seconds <= 0.5) {
        [statusItem setTitle:@"00:00"];
    } else {
        int intSeconds = (int)floor(seconds + 0.5);
        if (intSeconds >= 15 * 60)
            intSeconds /= 60;
        NSString *text = [NSString stringWithFormat:@"%d:%.2d", intSeconds / 60, intSeconds % 60];
        [statusItem setTitle:text];
    }
}

- (void)setUpForStateIdle {
    state = MBTS_INVALID;
    [statusItem setTitle:@"Timer"];
    state = MBTS_IDLE;
}

- (void)setUpForStateTiming:(double)seconds {
    state = MBTS_INVALID;
    [menuItemOfPauseOrContinue setTitle:@"Pause"];
    timingSeconds = seconds;
    [self renderSeconds:timingSeconds];
    NSInvocation *invocation = [NSInvocation
                                invocationWithMethodSignature:
                                [self methodSignatureForSelector:@selector(timingTick)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(timingTick)];
    timingTimer = [NSTimer
                   timerWithTimeInterval:1
                   invocation:invocation
                   repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timingTimer forMode:NSRunLoopCommonModes];
    state = MBTS_TIMING;
}

- (void)timingTick {
    timingSeconds -= 1;
    if (timingSeconds <= 0) {
        [timingTimer invalidate];
        timingTimer = nil;
        [self setUpForStateFinished];
        return;
    }
    [self renderSeconds:timingSeconds];
}

- (void)setUpForStatePaused {
    state = MBTS_INVALID;
    
    // time
    [timingTimer invalidate];
    timingTimer = nil;
    if (timingSeconds <= 0) {
        [self setUpForStateFinished];
        return;
    }
    [self renderSeconds:timingSeconds];
    
    // menu
    [menuItemOfPauseOrContinue setTitle:@"Continue"];
    
    state = MBTS_PAUSED;
}

- (void)setUpForStateFinished {
    [self setUpForStateIdle];
}

@end
