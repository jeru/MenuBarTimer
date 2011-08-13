//
//  MenuBarTimerAppDelegate.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyStatusMenuDelegate.h"

@interface MenuBarTimerAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSTextField *durationInput;
    IBOutlet NSView *duarationInputView;
    NSStatusItem *statusItem;
}

- (IBAction)openStatusItem:(id)sender;

@end
