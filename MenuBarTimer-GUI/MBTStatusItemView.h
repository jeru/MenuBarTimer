//
//  MBTStatusItemView.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MBTStatusItemView : NSView {
    NSStatusItem *_statusItem;

    NSString *_title;
    NSRect _titleRect;

    BOOL _highlight;
    
    id _target;
    SEL _actionOnHighlight;
    SEL _actionOnUnhighlight;
    
    BOOL _blinking;
    NSTimer *_blinkTimer;
    BOOL _blinkMode;
}

- (void)setTitle:(NSString*)aTitle;
- (NSString*)title;

- (void)setHighlight:(BOOL)aVal;
- (BOOL)highlight;

- (void)setTarget:(id)theTarget;
- (id)target;
- (void)setActionOnHighlight:(SEL)aSelector;
- (SEL)actionOnHighlight;
- (SEL)actionOnUnhighlight;
- (void)setActionOnUnhighlight:(SEL)aSelector;

- (void)setBlinking:(BOOL)aVal;
- (BOOL)blinking;

@end
