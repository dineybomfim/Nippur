/*
 *	NPPKeyboardToolbar.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 02/27/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPButton.h"
#import "NPPWindowKeyboard.h"

typedef enum
{
	NPPKeyboardActionSet		= 1,
	NPPKeyboardActionPrevious	= 2,
	NPPKeyboardActionNext		= 3,
} NPPKeyboardAction;

// UIKit Keyboard protocol.
@protocol NPPKeyboardDelegate <NSObject>

@optional
- (void) keyboardWillShow;
- (void) keyboardWillHide;
- (void) keyboardDoneAction;
- (BOOL) keyboardShouldNavigateTo:(UIView *)item onAction:(NPPKeyboardAction)action;
- (BOOL) keyboardShouldChange:(UIView *)item string:(NSString *)string inRange:(NSRange)range;
- (void) keyboardDidChange:(UIView *)item;

@end

// The global keyboard.
@interface NPPKeyboardToolbar : NSObject

+ (void) setItemsWithArray:(NSArray *)array;
+ (void) setItems:(UIView *)first, ... NS_REQUIRES_NIL_TERMINATION;
+ (UIView *) currentItem;
+ (void) setCurrentItem:(UIView *)item;
+ (void) restoreLastItem;
+ (void) resetAll;
+ (NSArray *) allItems;

+ (void) setButtons:(UIButton *)first, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) setNavigationWithTarget:(id <NPPKeyboardDelegate>)target
				   arrowsButtons:(BOOL)arrows
					 doneButton:(BOOL)button;
+ (void) setDoneButtonTitle:(NSString *)title highlighted:(BOOL)isBlue;
+ (void) setHiddenButtons:(BOOL)isHidden;

+ (void) showToolbar;
+ (void) hideToolbar;
+ (void) setAutoMoveScrollView:(BOOL)enabled; // Default is YES.

@end