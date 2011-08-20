//
//  MenuBarTimerAppDelegate.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBTStatusItem.h"

@interface MenuBarTimerAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextField *durationInput;
    IBOutlet NSPanel *windowForInput;
    IBOutlet NSButton *toggleStartOnLogin;
    
    MBTStatusItem *statusItem;
}

- (void)clickStatusItem:(id)sender;

- (IBAction)clickGo:(id)sender;
- (IBAction)clickCancel:(id)sender;
- (IBAction)toggleLoginItem:(id)sender;

@end
