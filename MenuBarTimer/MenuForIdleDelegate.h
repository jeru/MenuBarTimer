//
//  MyStatusMenuDelegate.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyStatusMenuDelegate : NSObject <NSMenuDelegate> {
    IBOutlet NSTextField *durationInput;
    NSTimer* focusingTimer;
}

- (void)menuWillOpen:(NSMenu *)menu;
- (void)menuNeedsUpdate:(NSMenu *)menu;

- (void)focusingTimerFire:(NSTimer*)theTimer;

@end