//
//  DurationInputDelegate.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 13/8/11.
//  Copyright 2011 The Chinese University of Hong Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DurationInputDelegate : NSObject <NSTextFieldDelegate> {
    IBOutlet NSButton *goButton;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;

@end
