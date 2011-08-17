//
//  MBTTimerStatusItem.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 17/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTStatusItem.h"

enum MBTTimerStatusItemState {
    MBTTimerStatusItemStateIdle,
    MBTTimerStatusItemStateTiming,
    MBTTimerStatusItemStateSuspended,
    MBTTimerStatusItemStateFinished
};

@interface MBTTimerStatusItem : NSObject {
    enum MBTTimerStatusItemState _state;
    id target;
    SEL actionOnCancel;
    NSTimer *_timer;
    double _remainingSeconds;
    MBTStatusItem *_statusItem;
    NSMenu *_menu;
    NSMenuItem *_menuItemPauseOrContinue;
    NSMenuItem *_menuItemStop;
    NSMenuItem *_menuItemExit;
}

- (void)start:(double)seconds;
- (void)cancel;
- (void)destroy;
@property(readwrite, assign) id target;
/*! @property actionOnCancel The signature is
 * "- (void)cancel:(MBTTimerStatusItem*)item".
 */
@property(readwrite, assign) SEL actionOnCancel;

@end
