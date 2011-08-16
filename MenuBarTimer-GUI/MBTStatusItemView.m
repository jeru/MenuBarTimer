//
//  MBTStatusItemView.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTStatusItemView.h"
#import "MBTUtils.h"

// Hack to obtain position. Fuck Apple!
@interface NSStatusItem (Hack)
- (NSWindow*)windowHack;
@end
@implementation NSStatusItem (Hack)
- (NSWindow*)windowHack {
    return [self valueForKeyPath:@"_fWindow"];
}
@end

///////////////////////
// MBTStatusItemView //
///////////////////////
@interface MBTStatusItemView () {
@private
    NSPanel *_poppedPanel;
    NSMenu *_poppedMenu;
}
@end
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
        _attributedTitle = nil;
        [self setTitle:@""];
        
        _state = MBTStatusItemViewStateNormal;
        _target = nil;
        _actionOnNormal = nil;
        _actionOnHighlighted = nil;
        _actionOnBlinking = nil;
        _blinkTimer = nil;
        
        _poppedPanel = nil;
        _poppedMenu = nil;
    }
    
    return self;
}

- (void)dealloc {
    [_title release];
    [_attributedTitle release];
    [_statusItem release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    BOOL realHighlight = 
            (_state == MBTStatusItemViewStateHighlighted
             || (_state == MBTStatusItemViewStateBlinking
                 && _blinkMode));
    CGFloat padding_height = ([[_statusItem statusBar] thickness]
                              - _titleRect.size.height + 1) / 2;
    NSColor *fontColor = realHighlight ? [NSColor whiteColor]
                                       : [NSColor blackColor];
    [_statusItem drawStatusBarBackgroundInRect:[self bounds]
                                 withHighlight:realHighlight];
    BOOL titleIsColored = NO;
    {
        NSRange r;
        for (NSUInteger i = 0; i < [_attributedTitle length];) {
            if ([[_attributedTitle attributesAtIndex:0
                                      effectiveRange:&r]
                 objectForKey:NSForegroundColorAttributeName] != nil)
            {
                titleIsColored = YES;
                break;
            }
            i = r.location + r.length;
        }
    }
    if (titleIsColored) {
        [_attributedTitle
         drawAtPoint:NSMakePoint(PADDING_WIDTH, padding_height)];
    } else {
        NSMutableAttributedString *s = [NSMutableAttributedString new];
        [s initWithAttributedString:_attributedTitle];
        [s addAttribute:NSForegroundColorAttributeName
                  value:fontColor
                  range:NSMakeRange(0, [_attributedTitle length])];
        [s drawAtPoint:NSMakePoint(PADDING_WIDTH, padding_height)];
        [s release];
    }
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
    NSAttributedString *s =
            [[NSAttributedString new]
             initWithString:aTitle
             attributes:[NSDictionary
                         dictionaryWithObjectsAndKeys:
                         [NSFont menuBarFontOfSize:0], NSFontAttributeName,
                         nil]];
    [self setAttributedTitle:s];
    [s release];
}

- (NSString*)title {
    return _title;
}

- (void)setAttributedTitle:(NSAttributedString *)aTitle {
    if ([aTitle isEqualToAttributedString:_attributedTitle]) return;
    if (_title != nil) [_title release];
    if (_attributedTitle != nil) [_attributedTitle release];
    _attributedTitle = [aTitle retain];
    _title = [_attributedTitle string];
    _titleRect = [_attributedTitle
                  boundingRectWithSize:NSMakeSize(INFINITY, INFINITY)
                  options:0];
    [_statusItem setLength:_titleRect.size.width + PADDING_WIDTH * 2];
    [self setNeedsLayout:YES];
}

- (NSAttributedString*)attributedTitle {
    return _attributedTitle;
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

- (NSRect)statusItemFrame {
    return [[_statusItem windowHack] frame];
}

- (void)clearPopped {
    if (_poppedMenu) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:@"NSMenuDidEndTrackingNotification"
         object:_poppedMenu];
        [_poppedMenu cancelTracking];
        _poppedMenu = nil;
    }
    if (_poppedPanel) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:@"NSWindowDidResignKeyNotification"
         object:_poppedPanel];
        [_poppedPanel orderOut:self];
        _poppedPanel = nil;
    }
}

- (void)cancelPopped:(NSNotification*)notif {
    [self setState:MBTStatusItemViewStateNormal];
    [self clearPopped];
}

- (void)popUpMenu:(NSMenu*)theMenu {
    [self setState:MBTStatusItemViewStateHighlighted];
    [theMenu cancelTracking];
    [self clearPopped];
    _poppedMenu = theMenu;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(cancelPopped:)
     name:@"NSMenuDidEndTrackingNotification"
     object:_poppedMenu];
    [_statusItem popUpStatusItemMenu:_poppedMenu];
}

- (void)popUpPanel:(NSPanel *)thePanel {
    [self setState:MBTStatusItemViewStateHighlighted];
    [self clearPopped];
    [thePanel orderOut:self];
    _poppedPanel = thePanel;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(cancelPopped:)
     name:@"NSWindowDidResignKeyNotification"
     object:_poppedPanel];
    NSRect r = [self statusItemFrame];
    NSPoint p = [MBTUtils
                 determinePopUpPosition:[thePanel frame].size
                 statusItem:r];
    [_poppedPanel setFrameOrigin:p];
    [_poppedPanel setMovable:NO];
    [_poppedPanel makeKeyAndOrderFront:self];
}

@end
