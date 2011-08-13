//
//  MenuBarTimerAppDelegate.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MenuBarTimerAppDelegate.h"

@implementation MenuBarTimerAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)awakeFromNib {
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Status Item"];
    [statusItem setHighlightMode:YES];
}

- (IBAction)openStatusItem:(id)sender {
    NSLog(@"Hello\n");
}

@end
