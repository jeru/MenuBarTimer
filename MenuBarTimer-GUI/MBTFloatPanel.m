//
//  MBTFloatPanel.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTFloatPanel.h"

@implementation MBTFloatPanel

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)cancelOperation:(id)sender {
    [self orderOut:sender];
}

- (void)resignKeyWindow {
    [super resignKeyWindow];
    [self cancelOperation:self];
}

@end
