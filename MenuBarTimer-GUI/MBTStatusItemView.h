//
//  MBTStatusItemView.h
//  MenuBarTimer
//
//  Created by Cheng Sheng on 15/8/11.
//  Copyright 2011 Cheng Sheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * @enum MBTStatusItemViewState
 * @abstract The possible values of the @link state @/link property of
 *           @link MBTStatusItemView @/link.
 * @constant MBTStatusItemViewStateNormal Normal (not highlighted, not
 *           blinking).
 * @constant MBTStatusItemViewStateHighlighed Highlighted.
 * @constant MBTStatusItemViewStateBlinking Blinking.
 */
enum MBTStatusItemViewState {
    MBTStatusItemViewStateNormal,
    MBTStatusItemViewStateHighlighted,
    MBTStatusItemViewStateBlinking
};

/*!
 * @interface MBTStatusItemView 
 * This interface creates an NSStatusItem and displays a text designated by
 * @link title @/link property. It can support popping up a panel or menu via
 * @link popUpPanel: @/link or @link popUpMenu: @/link, which shows the panel or menu
 * attached tothe status item on the status bar, highlighted. When the panel
 * loses keyboard focus or the menu gets untracked, it hides the panel or menu,
 * and unhighlight the status item.
 *
 * @link MBTStatusItemView @/link provides a property @link state @/link to control
 * the highlighting directly. When @link state @/link is
 * @link MBTStatusItemViewStatesNormal @/link, the status item is not highlighed;
 * when it is @link MBTStatusItemViewStatesHighlighted @/link, the status item is
 * highlighed; when it is @link MBTStatusItemViewStatesBlinking @/link, the
 * status item will blink.
 *
 * When the status item of @link MBTStatusItemView @/link is clicked, an action
 * will be invoked, selected from properties @link actionOnNormal @/link,
 * @link actionOnHighlighted @/link and @link actionOnBlinking @/link accordingly by
 * the current @link state @/link.
 */
@interface MBTStatusItemView : NSView {
@private
    NSStatusItem *_statusItem;

    NSString *_title;
    NSAttributedString *_attributedTitle;
    NSRect _titleRect;
    
    enum MBTStatusItemViewState _state;
    BOOL _blinkMode;
    NSTimer *_blinkTimer;
    
    id _target;
    SEL _actionOnNormal;
    SEL _actionOnHighlighted;
    SEL _actionOnBlinking;
}

/*! @property title */
- (void)setTitle:(NSString*)aTitle;
- (NSString*)title;

/*! @property attributedTitle */
- (void)setAttributedTitle:(NSAttributedString*)aTitle;
- (NSAttributedString*)attributedTitle;

/*! @method setTitle:withColor: */
- (void)setTitle:(NSString*)aTitle withColor:(NSColor*)aColor;

/*! @property state */
- (void)setState:(enum MBTStatusItemViewState)theState;
- (enum MBTStatusItemViewState)state;

/*! @property target */
- (void)setTarget:(id)theTarget;
- (id)target;

/*! @property actionOnNormal */
- (void)setActionOnNormal:(SEL)aSelector;
- (SEL)actionOnNormal;

/*! @property actionOnHighlighted */
- (void)setActionOnHighlighted:(SEL)aSelector;
- (SEL)actionOnHighlighted;

/*! @property actionOnBlinking */
- (void)setActionOnBlinking:(SEL)aSelector;
- (SEL)actionOnBlinking;

- (NSRect)statusItemFrame;

/*! @method popUpMenu: */
- (void)popUpMenu:(NSMenu*)theMenu;

/*! @method popUpPanel: */
- (void)popUpPanel:(NSPanel*)thePanel;

@end
