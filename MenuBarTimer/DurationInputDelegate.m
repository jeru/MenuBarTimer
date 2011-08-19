//
//  DurationInputDelegate.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 19/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "DurationInputDelegate.h"

@implementation DurationInputDelegate

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)textView
doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(cancelOperation:)) {
        [self sendAction:self.action to:self.target];
        return YES;
    }
    return NO;
}

@end
