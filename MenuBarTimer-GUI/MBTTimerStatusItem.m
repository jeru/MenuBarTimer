//
//  MBTTimerStatusItem.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 17/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTTimerStatusItem.h"

#import "MBTUtils.h"

// TODO: more accurate timing mechanism is needed.
@implementation MBTTimerStatusItem
@synthesize actionOnCancel;
@synthesize target;

- (void)_displayTime {
    if (_state == MBTTimerStatusItemStateFinished) {
        if ([_statusItem state] != MBTStatusItemViewStateBlinking)
            [_statusItem setState:MBTStatusItemViewStateBlinking];
    } else {
        if ([_statusItem state] == MBTStatusItemViewStateBlinking)
            [_statusItem setState:MBTStatusItemViewStateNormal];
    }
    NSString *time = [MBTUtils renderTime:
                      (_remainingSeconds < 0 ? 0.0 : _remainingSeconds)];
    if (_state == MBTTimerStatusItemStateSuspended)
        [_statusItem setTitle:time withColor:[NSColor darkGrayColor]];
    else
        [_statusItem setTitle:time];
}

- (void)_startTimer {
    _timer = [NSTimer
              timerWithTimeInterval:1 
              target:self
              selector:@selector(_timerFired:)
              userInfo:nil
              repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer
                                 forMode:NSRunLoopCommonModes];
}

- (void)_stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)_timerFired:(NSTimer*)theTimer {
    _remainingSeconds -= 1;
    [self _displayTime];
    if (_remainingSeconds <= 0) {
        [self _stopTimer];
        _state = MBTTimerStatusItemStateFinished;
        [self _displayTime];
    }
}

- (void)_clickPauseOrContinue:(id)sender {
    if (_state == MBTTimerStatusItemStateTiming) {
        // To pause...
        [self _stopTimer];
        _state = MBTTimerStatusItemStateSuspended;
        [self _displayTime];
    } else if (_state == MBTTimerStatusItemStateSuspended) {
        // To continue...
        _state = MBTTimerStatusItemStateTiming;
        [self _displayTime];
        [self _startTimer];
    }
}

- (void)_clickStop:(id)sender {
    [self cancel];
}

- (void)_clickExit:(id)sender {
    [NSApp terminate:self];
}

- (void)_popMenu:(id)sender {
    if (_state == MBTTimerStatusItemStateTiming) {
        [_menuItemPauseOrContinue setTitle:
         NSLocalizedString(@"Pause",
                           @"Suspend the timer.")];
    } else {
        [_menuItemPauseOrContinue setTitle:
         NSLocalizedString(@"Continue",
                           @"Resume the timer.")];
    }
    [_statusItem popUpMenu:_menu];
}

- (void)_cancelMenu:(id)sender {
    [_menu cancelTracking];
}

- (void)_stopBlinking:(id)sender {
    [self cancel];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _timer = nil;
        _remainingSeconds = -1;
        _state = MBTTimerStatusItemStateIdle;
        
        // Setup the menu.
        _menu = [NSMenu new];
        _menuItemPauseOrContinue = [NSMenuItem new]; {
            [_menu addItem:_menuItemPauseOrContinue];
            [_menuItemPauseOrContinue setTarget:self];
            [_menuItemPauseOrContinue
             setAction:@selector(_clickPauseOrContinue:)];
            [_menuItemPauseOrContinue setEnabled:YES];
        }
        _menuItemStop = [NSMenuItem new]; {
            [_menu addItem:_menuItemStop];
            [_menuItemStop setTarget:self];
            [_menuItemStop
             setAction:@selector(_clickStop:)];
            [_menuItemStop setTitle:
             NSLocalizedString(@"Stop",
                               @"Cancel the timer.")];
            [_menuItemStop setEnabled:YES];
        }
        [_menu addItem:[NSMenuItem separatorItem]];
        _menuItemExit = [NSMenuItem new]; {
            [_menu addItem:_menuItemExit];
            [_menuItemExit setTarget:self];
            [_menuItemExit
             setAction:@selector(_clickExit:)];
            [_menuItemExit setTitle:
             NSLocalizedString(@"Exit",
                               @"Quit the application.")];
            [_menuItemExit setEnabled:YES];
        }

        _statusItem = [MBTStatusItem new];
        [_statusItem setTarget:self];
        [_statusItem setActionOnNormal:
         @selector(_popMenu:)];
        [_statusItem setActionOnHighlighted:
         @selector(_cancelMenu:)];
        [_statusItem setActionOnBlinking:
         @selector(_stopBlinking:)];
        [_statusItem setActionOnCancelPopped:
         @selector(_stopBlinking:)];
    }
    
    return self;
}

- (void)destroy {
    if (_statusItem) {
        [_statusItem destroy];
        [_statusItem release];
        _statusItem = nil;
    }
}

- (void)dealloc {
    if (_timer) [_timer release];
    if (_menuItemPauseOrContinue) [_menuItemPauseOrContinue release];
    if (_menuItemStop) [_menuItemStop release];
    if (_menuItemExit) [_menuItemExit release];
    if (_menu) [_menu release];
    if (_statusItem) [_statusItem release];
    [super dealloc];
}

- (void)start:(double)seconds {
    if (seconds <= 0) return;
    [self _stopTimer];
    _remainingSeconds = seconds;
    _state = MBTTimerStatusItemStateTiming;
    [self _displayTime];
    [self _startTimer];
}

- (void)cancel {
    [self _stopTimer];
    _remainingSeconds = -1;
    _state = MBTTimerStatusItemStateIdle;
    [self _displayTime];
    if (actionOnCancel) {
        [target performSelector:actionOnCancel
                      withObject:self];
    }
}

@end
