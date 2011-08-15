//
//  DurationInputDelegate.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "DurationInputDelegate.h"

@implementation DurationInputDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [goButton performClick:self];
        return YES;
    } else if (commandSelector == @selector(cancelOperation:)) {
        [cancelButton performClick:self];
        return YES;
    }
    return NO;
}

@end
