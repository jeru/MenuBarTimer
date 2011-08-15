//
//  MBTStatusItemView.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum MBTStatusItemViewState {
    MBTStatusItemViewStateNormal,
    MBTStatusItemViewStateHighlighted,
    MBTStatusItemViewStateBlinking
};

@interface MBTStatusItemView : NSView {
    NSStatusItem *_statusItem;

    NSString *_title;
    NSRect _titleRect;
    
    enum MBTStatusItemViewState _state;
    BOOL _blinkMode;
    NSTimer *_blinkTimer;
    
    id _target;
    SEL _actionOnNormal;
    SEL _actionOnHighlighted;
    SEL _actionOnBlinking;
}

- (void)setTitle:(NSString*)aTitle;
- (NSString*)title;

- (void)setState:(enum MBTStatusItemViewState)theState;
- (enum MBTStatusItemViewState)state;

- (void)setTarget:(id)theTarget;
- (id)target;
- (void)setActionOnNormal:(SEL)aSelector;
- (SEL)actionOnNormal;
- (void)setActionOnHighlighted:(SEL)aSelector;
- (SEL)actionOnHighlighted;
- (void)setActionOnBlinking:(SEL)aSelector;
- (SEL)actionOnBlinking;

@end
