//
//  MenuBarTimerAppDelegate.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MenuBarTimerAppDelegate.h"
#import "MBTStatusItem.h"
#import "MBTTimerStatusItem.h"
#import "MBTUtils.h"

/////////////////////////////
// Some utility functions. //
/////////////////////////////


static void AutomatonPanic(NSString* msg) {
    NSLog(@"AutomanonPanic: %@", msg);
    for (;;);
}

/////////////////////////////
// MenuBarTimerAppDelegate //
/////////////////////////////

@interface MenuBarTimerAppDelegate () {
@private
    NSMutableSet *timersInRun;
}
- (void)renderSeconds:(double)seconds;
- (void)executeGo:(id)sender;
- (void)executeCancel:(id)sender;
@end

@implementation MenuBarTimerAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    timersInRun = [[NSMutableSet alloc] init];
}

- (void)dealloc {
    if (timersInRun) {
        for (id obj in timersInRun)
            [obj release];
        [timersInRun removeAllObjects];
        [timersInRun release];
        timersInRun = nil;
    }
    [super dealloc];
}

- (void)clickStatusItem:(id)sender {
    if ([windowForInput isVisible]) {
        [windowForInput orderOut:sender];
    } else {
        [statusItem popUpPanel:windowForInput];
        [durationInput selectText:self];
    }
}

- (void)executeGo:(id)sender {
    NSString *text = [durationInput stringValue];
    int time = [MBTUtils parseTimeString:text];
    if (time < 0) {
        NSAlert *theAlert = [NSAlert
                             alertWithMessageText:@"Something wrong"
                             defaultButton:@"OK"
                             alternateButton:nil
                             otherButton:nil
                             informativeTextWithFormat:@"Don't know what the time string means: %s.", text];
        [theAlert runModal];
    } else {
        [windowForInput orderOut:sender];
        //[self setUpForStateTiming:time];
        MBTTimerStatusItem *timer = [[MBTTimerStatusItem alloc] init];
        [timersInRun addObject:timer];
        [timer setTarget:self];
        [timer setActionOnCancel:@selector(cancelTimer:)];
        [timer start:time];
    }
}

- (void)awakeFromNib {
    statusItem = [[MBTStatusItem alloc] init];
    [statusItem setTarget:self];
    [statusItem setActionOnNormal:@selector(clickStatusItem:)];
    [statusItem setActionOnHighlighted:@selector(clickStatusItem:)];
    [statusItem setActionOnBlinking:@selector(clickStatusItem:)];
    //[statusItem setTitle:@"Timer"];
    NSBundle *bundle = [NSBundle mainBundle];
    {
        NSString *path = [bundle pathForResource:@"clock" ofType:@"png"];
        NSImage *img = [NSImage alloc];
        img = [img initWithContentsOfFile:path];
        [statusItem setImage:img];
        [img release];
    }
    {
        NSString *path = [bundle pathForResource:@"inverted_clock" ofType:@"png"];
        NSImage *img = [NSImage alloc];
        img = [img initWithContentsOfFile:path];
        [statusItem setAlternativeImage:img];
        [img release];
    }
}

- (void)cancelTimer:(MBTTimerStatusItem*)item {
    [item destroy];
    [item release];
    [timersInRun removeObject:item];
}

- (IBAction)clickGo:(id)sender {
    [self executeGo:sender];
}


- (IBAction)clickCancel:(id)sender {
    [self executeCancel:sender];
}

- (void)executeCancel:(id)sender {
    [windowForInput orderOut:sender];
}

- (void)renderSeconds:(double)seconds {
    [statusItem setTitle:[MBTUtils renderTime:seconds]];
}

@end
