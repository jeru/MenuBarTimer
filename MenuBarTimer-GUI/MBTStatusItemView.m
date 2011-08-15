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
        
        _highlight = NO;
        _target = nil;
        _actionOnHighlight = nil;
        _actionOnUnhighlight = nil;
        
        _blinking = NO;
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
    BOOL realHighlight = _blinking ? _blinkMode : _highlight;
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
    if (_highlight) {
        if ([_target respondsToSelector:_actionOnHighlight]) {
            BOOL ret = [_target performSelector:_actionOnHighlight
                                     withObject:self];
            [self setHighlight:ret];
        }
    } else {
        if ([_target respondsToSelector:_actionOnUnhighlight]) {
            [self setHighlight:YES];
            BOOL ret = [_target performSelector:_actionOnUnhighlight
                                     withObject:self];
            [self setHighlight:ret];
        }
    }
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

- (void)setHighlight:(BOOL)aVal {
    if (aVal != _highlight) {
        _highlight = aVal;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)highlight {
    return _highlight;
}

- (void)setTarget:(id)theTarget {
    _target = theTarget;
}

- (id)target {
    return _target;
}

- (void)setActionOnHighlight:(SEL)aSelector {
    _actionOnHighlight = aSelector;
}

- (SEL)actionOnHighlight {
    return _actionOnHighlight;
}

- (void)setActionOnUnhighlight:(SEL)aSelector {
    _actionOnUnhighlight = aSelector;
}

- (SEL)actionOnUnhighlight {
    return _actionOnUnhighlight;
}

- (void)blinkTimerFired:(NSTimer*)timer {
    _blinkMode = !_blinkMode;
    [self setNeedsDisplay:YES];
}

- (void)setBlinking:(BOOL)aVal {
    if (aVal != _blinking) return;
    if (aVal) {
        _blinking = YES;
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
    } else {
        [_blinkTimer invalidate];
        _blinkTimer = nil;
        _blinkMode = NO;
        _blinking = NO;
    }
    [self setNeedsDisplay:YES];
}

- (BOOL)blinking {
    return _blinking;
}

@end
