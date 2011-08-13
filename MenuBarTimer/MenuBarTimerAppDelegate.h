//
//  MenuBarTimerAppDelegate.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenuForIdleDelegate.h"

enum MenuBarTimerState {
    MBTS_IDLE,
    MBTS_TIMING,
    MBTS_PAUSED,
    MBTS_FINISHED,
    
    MBTS_INVALID
};

@interface MenuBarTimerAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *menuForStateIdle;
    IBOutlet NSMenu *menuForStateTimingOrPaused;
    IBOutlet NSMenuItem *menuItemOfPauseOrContinue;
    IBOutlet NSTextField *durationInput;
    IBOutlet NSView *durationInputView;
    NSStatusItem *statusItem;
    
    enum MenuBarTimerState state;
    NSMenuItem *clickPauseOrContinue;
}

- (IBAction)openStatusItem:(id)sender;
- (IBAction)clickGo:(id)sender;
- (IBAction)clickPauseOrContinue:(id)sender;
- (IBAction)clickStop:(id)sender;

@end
