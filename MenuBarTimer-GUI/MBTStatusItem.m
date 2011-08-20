//
//  MBTStatusItem.m
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import "MBTStatusItem.h"
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

////////////////////////
// _MBTStatusItemView //
////////////////////////
@interface _MBTStatusItemView : NSView {
@private
    NSStatusItem *_statusItem;
    
    NSString *_title;
    NSAttributedString *_attributedTitle;
    NSRect _titleRect;
    
    NSImage *_image;
    NSImage *_alternativeImage;
    
    enum MBTStatusItemViewState _state;
    BOOL _blinkMode;
    NSTimer *_blinkTimer;
    
    NSPanel *_poppedPanel;
    NSMenu *_poppedMenu;
}

- (void)setTitle:(NSString*)aTitle;
- (NSString*)title;

- (void)setAttributedTitle:(NSAttributedString*)aTitle;
- (NSAttributedString*)attributedTitle;

- (void)setTitle:(NSString*)aTitle withColor:(NSColor*)aColor;

- (void)setImage:(NSImage*)anImage;
- (NSImage*)image;
- (void)setAlternativeImage:(NSImage*)anImage;
- (NSImage*)alternativeImage;

- (void)setState:(enum MBTStatusItemViewState)theState;
- (enum MBTStatusItemViewState)state;

@property(nonatomic, assign) id target;
@property(readwrite, assign) SEL actionOnNormal;
@property(readwrite, assign) SEL actionOnHighlighted;
@property(readwrite, assign) SEL actionOnBlinking;
@property(readwrite, assign) SEL actionOnCancelPopped;

- (NSRect)statusItemFrame;

- (void)popUpMenu:(NSMenu*)theMenu;

- (void)popUpPanel:(NSPanel*)thePanel;

- (void)destroy;

@end

@implementation _MBTStatusItemView
@synthesize target;
@synthesize actionOnNormal;
@synthesize actionOnHighlighted;
@synthesize actionOnBlinking;
@synthesize actionOnCancelPopped;

#define PADDING_WIDTH 6
#define BLINK_PERIOD 0.5

- (id)init {
    self = [super init];
    if (self) {
        _statusItem = [[[NSStatusBar systemStatusBar]
                        statusItemWithLength:1]
                       retain];
        // Initialization code here.
        _title = nil;
        _attributedTitle = nil;
        [self setTitle:@""];
        
        _image = nil;
        _alternativeImage = nil;
        
        _state = MBTStatusItemViewStateNormal;
        _blinkTimer = nil;
        
        _poppedPanel = nil;
        _poppedMenu = nil;

        [_statusItem setView:self];
    }
    
    return self;
}

- (void)dealloc {
    [_title release];
    [_attributedTitle release];
    if (_statusItem) {
        [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
        [_statusItem release];
    }
    if (_image) [_image release];
    if (_alternativeImage) [_alternativeImage release];
    [super dealloc];
}

- (void)destroy {
    if (_statusItem) {
        [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
        [_statusItem release];
        _statusItem = nil;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    BOOL realHighlight = 
            (_state == MBTStatusItemViewStateHighlighted
             || (_state == MBTStatusItemViewStateBlinking
                 && _blinkMode));
    CGFloat txt_width = 0, txt_padding_height = 0;
    if (_titleRect.size.width > 0) {
        txt_width = _titleRect.size.width;
        txt_padding_height =
                ([[_statusItem statusBar] thickness]
                 - _titleRect.size.height + 1) / 2;
    }
    NSColor *fontColor = realHighlight ? [NSColor whiteColor]
                                       : [NSColor blackColor];
    CGFloat img_width = 0, img_padding_height = 0;
    NSImage *img = nil;
    if (!realHighlight) {
        if (_image)
            img = _image;
    } else {
        if (_alternativeImage)
            img = _alternativeImage;
        else if (_image)
            img = _image;
    }
    if (img) {
        img_width = [img size].width;
        img_padding_height =
                ([[_statusItem statusBar] thickness]
                 - [img size].height + 1) / 2;
    }
    CGFloat width = 0, txt_left = 0, img_left = 0;
    if (txt_width > 0 && img_width > 0) {
        width = PADDING_WIDTH * 3 + txt_width + img_width;
        txt_left = PADDING_WIDTH * 2 + img_width;
        img_left = PADDING_WIDTH;
    } else if (txt_width > 0 || img_width > 0) {
        width = PADDING_WIDTH * 2 + txt_width + img_width;
        txt_left = img_left = PADDING_WIDTH;
    }
    if (width == 0) width = 1;
    [_statusItem setLength:width];
    [_statusItem drawStatusBarBackgroundInRect:[self bounds]
                                 withHighlight:realHighlight];
    if (img) {
        /*
        NSCompositingOperation comp =
                realHighlight ? NSCompositeSourceAtop
                              : NSCompositeDestinationAtop;
         */
        NSCompositingOperation comp = NSCompositeSourceOver;
        [img drawAtPoint:NSMakePoint(img_left,
                                     img_padding_height)
                fromRect:NSZeroRect
               operation:comp
                fraction:1];
    }
    // Try this coloring method: if highlighted, white; otherwise,
    // the original color(s).
    if (!realHighlight) {
        [_attributedTitle
         drawAtPoint:NSMakePoint(txt_left,
                                 txt_padding_height)];
    } else {
        NSMutableAttributedString *s = [NSMutableAttributedString alloc];
        s = [s initWithAttributedString:_attributedTitle];
        [s removeAttribute:NSForegroundColorAttributeName
                     range:NSMakeRange(0, [s length])];
        [s addAttribute:NSForegroundColorAttributeName
                  value:fontColor
                  range:NSMakeRange(0, [_attributedTitle length])];
        [s drawAtPoint:NSMakePoint(txt_left,
                                   txt_padding_height)];
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
            action = actionOnNormal;
            break;
        case MBTStatusItemViewStateHighlighted:
            action = actionOnHighlighted;
            break;
        case MBTStatusItemViewStateBlinking:
            action = actionOnBlinking;
            break;
    }
    if ([target respondsToSelector:action])
        [target performSelector:action withObject:self];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [self mouseDown:theEvent];
}

- (NSFont*)font {
    return [NSFont menuBarFontOfSize:0];
}

- (void)_finishTitleSetting {
    _titleRect = [_attributedTitle
                  boundingRectWithSize:NSMakeSize(INFINITY, INFINITY)
                  options:0];
    [self setNeedsDisplay:YES];
}

- (void)setTitle:(NSString *)aTitle {
    NSString *origS = [aTitle retain];
    NSAttributedString *s =
    [[NSAttributedString alloc]
     initWithString:origS
     attributes:[NSDictionary
                 dictionaryWithObjectsAndKeys:
                 [self font], NSFontAttributeName,
                 nil]];
    if ([s isEqualToAttributedString:_attributedTitle]) {
        [s release];
        [origS release];
        return;
    }
    if (_title) [_title release];
    _title = origS;
    if (_attributedTitle) [_attributedTitle release];
    _attributedTitle = s;
    [self _finishTitleSetting];
}

- (NSString*)title {
    return _title;
}

- (void)setAttributedTitle:(NSAttributedString *)aTitle {
    if ([aTitle isEqualToAttributedString:_attributedTitle]) return;
    if (_title) [_title release];
    if (_attributedTitle) [_attributedTitle release];
    _attributedTitle = [aTitle retain];
    _title = [[_attributedTitle string] retain];
    [self _finishTitleSetting];
}

- (NSAttributedString*)attributedTitle {
    return _attributedTitle;
}

- (void)setTitle:(NSString*)aTitle withColor:(NSColor*)aColor {
    NSString *origS = [aTitle retain];
    NSAttributedString *s =
            [[NSAttributedString alloc]
             initWithString:origS
             attributes:[NSDictionary
                         dictionaryWithObjectsAndKeys:
                         [self font], NSFontAttributeName,
                         aColor, NSForegroundColorAttributeName,
                         nil]];
    if ([s isEqualToAttributedString:_attributedTitle]) {
        [s release];
        [origS release];
        return;
    }
    if (_title) [_title release];
    _title = origS;
    if (_attributedTitle) [_attributedTitle release];
    _attributedTitle = s;
    [self _finishTitleSetting];
}

- (void)setImage:(NSImage*)anImage {
    if (_image) [_image release];
    _image = [anImage retain];
    [self setNeedsDisplay:YES];
}

- (NSImage*)image {
    return _image;
}

- (void)setAlternativeImage:(NSImage*)anImage {
    if (_alternativeImage) [_alternativeImage release];
    _alternativeImage = [anImage retain];
    [self setNeedsDisplay:YES];
}

- (NSImage*)alternativeImage {
    return _alternativeImage;
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
    BOOL poppedCanceled = NO;
    if (_poppedMenu) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:@"NSMenuDidEndTrackingNotification"
         object:_poppedMenu];
        [_poppedMenu cancelTracking];
        _poppedMenu = nil;
        poppedCanceled = YES;
    }
    if (_poppedPanel) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:@"NSWindowDidResignKeyNotification"
         object:_poppedPanel];
        [_poppedPanel orderOut:self];
        _poppedPanel = nil;
        poppedCanceled = YES;
    }
    if (poppedCanceled
        && [target respondsToSelector:actionOnCancelPopped])
    {
        [target performSelector:actionOnCancelPopped
                     withObject:self];
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

///////////////////
// MBTStatusItem //
///////////////////

@interface MBTStatusItem () {
@private
    _MBTStatusItemView *_view;
}
@end

@implementation MBTStatusItem

- (id)init {
    self = [super init];
    if (self) {
        _view = [[_MBTStatusItemView alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (_view) {
        [_view release];
        _view = nil;
    }
    [super dealloc];
}

- (void)setTitle:(NSString*)aTitle {
    [_view setTitle:aTitle];
}

- (NSString*)title {
    return [_view title];
}

- (void)setAttributedTitle:(NSAttributedString*)aTitle {
    [_view setAttributedTitle:aTitle];
}

- (NSAttributedString*)attributedTitle {
    return [_view attributedTitle];
}

- (void)setTitle:(NSString*)aTitle withColor:(NSColor*)aColor {
    [_view setTitle:aTitle withColor:aColor];
}

- (void)setState:(enum MBTStatusItemViewState)theState {
    [_view setState:theState];
}

- (enum MBTStatusItemViewState)state {
    return [_view state];
}

- (void)setImage:(NSImage*)anImage {
    [_view setImage:anImage];
}

- (NSImage*)image {
    return [_view image];
}

- (void)setAlternativeImage:(NSImage*)anImage {
    [_view setAlternativeImage:anImage];
}

- (NSImage*)alternativeImage {
    return [_view alternativeImage];
}

- (void)setTarget:(id)theTarget {
    [_view setTarget:theTarget];
}

- (id)target {
    return [_view target];
}

- (void)setActionOnNormal:(SEL)aSelector {
    [_view setActionOnNormal:aSelector];
}

- (SEL)actionOnNormal {
    return [_view actionOnNormal];
}

- (void)setActionOnHighlighted:(SEL)aSelector {
    [_view setActionOnHighlighted:aSelector];
}

- (SEL)actionOnHighlighted {
    return [_view actionOnHighlighted];
}

- (void)setActionOnBlinking:(SEL)aSelector {
    [_view setActionOnBlinking:aSelector];
}

- (SEL)actionOnBlinking {
    return [_view actionOnBlinking];
}

- (void)setActionOnCancelPopped:(SEL)aSelector {
    [_view setActionOnCancelPopped:aSelector];
}

- (SEL)actionOnCancelPopped {
    return [_view actionOnCancelPopped];
}

- (NSRect)statusItemFrame {
    return [_view statusItemFrame];
}

- (void)popUpMenu:(NSMenu*)theMenu {
    [_view popUpMenu:theMenu];
}

- (void)popUpPanel:(NSPanel*)thePanel {
    [_view popUpPanel:thePanel];
}

- (void)destroy {
    [_view destroy];
}

@end
