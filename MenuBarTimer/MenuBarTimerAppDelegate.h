//
//  MenuBarTimerAppDelegate.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 The Chinese University of Hong Kong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MenuBarTimerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
