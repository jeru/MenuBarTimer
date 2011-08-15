//
//  MBTStatusItemView.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTStatusItemView.h"

@implementation MBTStatusItemView

#define PADDING_WIDTH 6
#define BLINK_PERIOD 0.5

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _statusItem = [[[NSStatusBar systemStatusBar]
                        statusItemWithLength:NSVariableStatusItemLength]
                       retain];
        [_statusItem setView:self];
        // Initialization code here.
        _title = nil;
        [self setTitle:@""];
        
        _state = MBTStatusItemViewStateNormal;
        _target = nil;
        _actionOnNormal = nil;
        _actionOnHighlighted = nil;
        _actionOnBlinking = nil;
        _blinkTimer = nil;
    }
    
    return self;
}

- (void)dealloc {
    [_title release];
    [_statusItem release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    BOOL realHighlight = 
            (_state == MBTStatusItemViewStateHighlighted
             || (_state == MBTStatusItemViewStateBlinking
                 && _blinkMode));
    CGFloat padding_height = ([[_statusItem statusBar] thickness]
                              - _titleRect.size.height) / 2;
    NSColor *fontColor = realHighlight ? [NSColor whiteColor]
                                       : [NSColor blackColor];
    [_statusItem drawStatusBarBackgroundInRect:[self bounds]
                                 withHighlight:realHighlight];
    [_title drawAtPoint:NSMakePoint(PADDING_WIDTH, padding_height)
         withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                         [NSFont menuBarFontOfSize:0], NSFontAttributeName,
                         fontColor, NSForegroundColorAttributeName,
                         nil]];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    SEL action = nil;
    switch (_state) {
        case MBTStatusItemViewStateNormal:
            action = _actionOnNormal;
            break;
        case MBTStatusItemViewStateHighlighted:
            action = _actionOnHighlighted;
            break;
        case MBTStatusItemViewStateBlinking:
            action = _actionOnBlinking;
            break;
    }
    if ([_target respondsToSelector:action])
        [_target performSelector:action withObject:self];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [self mouseDown:theEvent];
}

- (void)setTitle:(NSString *)aTitle {
    if (![aTitle isEqualToString:_title]) {
        if (_title != nil) [self.title release];
        _title = [aTitle retain];
        _titleRect = [_title
                      boundingRectWithSize:NSMakeSize(INFINITY, INFINITY)
                      options:0
                      attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSFont menuBarFontOfSize:0], NSFontAttributeName,
                                  nil]];
        [_statusItem setLength:_titleRect.size.width + PADDING_WIDTH * 2];
        [self setNeedsDisplay:YES];
    }
}

- (NSString*)title {
    return _title;
}

- (void)setTarget:(id)theTarget {
    _target = theTarget;
}

- (id)target {
    return _target;
}

- (void)setActionOnNormal:(SEL)aSelector {
    _actionOnNormal = aSelector;
}

- (SEL)actionOnNormal {
    return _actionOnNormal;
}

- (void)setActionOnHighlighted:(SEL)aSelector {
    _actionOnHighlighted = aSelector;
}

- (SEL)actionOnHighlighted {
    return _actionOnHighlighted;
}

- (void)setActionOnBlinking:(SEL)aSelector {
    _actionOnBlinking = aSelector;
}

- (SEL)actionOnBlinking {
    return _actionOnBlinking;
}

- (void)blinkTimerFired:(NSTimer*)timer {
    _blinkMode = !_blinkMode;
    [self setNeedsDisplay:YES];
}

- (void)setState:(enum MBTStatusItemViewState)theState {
    if (theState == _state) return;
    if (_state == MBTStatusItemViewStateBlinking) {
        [_blinkTimer invalidate];
        _blinkTimer = nil;
    }
    _state = theState;
    if (_state == MBTStatusItemViewStateBlinking) {
        _blinkMode = YES;
        _blinkTimer = [NSTimer
                       timerWithTimeInterval:BLINK_PERIOD
                       target:self
                       selector:@selector(blinkTimerFired:)
                       userInfo:nil
                       repeats:YES];
        [[NSRunLoop currentRunLoop]
         addTimer:_blinkTimer
         forMode:NSRunLoopCommonModes];
    }
    [self setNeedsDisplay:YES];
}

- (enum MBTStatusItemViewState)state {
    return _state;
}

@end
