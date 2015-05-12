/*
 *	NPPWindowOverlay.h
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

@interface NPPWindowOverlay : UIViewController
{
@private
	NSMutableArray				*_children;
	UIView						*_viBackground;
	UIView						*_viHolder;
	NPPWindow					*_window;
}

NPP_SINGLETON_INTERFACE(NPPWindowOverlay);

@property (nonatomic, NPP_RETAIN) UIView *backgroundView;

- (void) addView:(UIView *)view;
- (void) removeView:(UIView *)view;

- (unsigned int) viewsCount;

@end