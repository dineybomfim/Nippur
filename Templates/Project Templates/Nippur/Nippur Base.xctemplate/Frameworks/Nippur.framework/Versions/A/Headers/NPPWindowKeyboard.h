/*
 *	NPPWindowKeyboard.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/18/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPWindow.h"

@interface NPPWindowKeyboard : UIViewController
{
@private
	BOOL					_autoAdjustToKeyboard;
	float					_heightExtra;
	CGRect					_validFrame;
	UIView					*_holderView;
	NPPWindow				*_window;
}

NPP_SINGLETON_INTERFACE(NPPWindowKeyboard);

@property (nonatomic) BOOL autoAdjustToKeyboard; // Default YES.
@property (nonatomic) float heightWindow; // Default equals to current UIKeyboard.
@property (nonatomic) float heightExtra; // Default 0.
@property (nonatomic, readonly) CGRect frameFull;

- (void) addView:(UIView *)view;
- (void) addView:(UIView *)view atIndex:(int)index;
- (void) removeView:(UIView *)view;
- (void) removeViewAtIndex:(int)index;

- (unsigned int) viewsCount;

- (void) showAnimated:(BOOL)animated completion:(NPPBlockVoid)block;
- (void) hideAnimated:(BOOL)animated completion:(NPPBlockVoid)block;

@end