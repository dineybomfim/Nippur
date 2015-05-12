/*
 *	NPPStatusBar.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 11/3/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"

@interface NPPStatusBar : NSObject
{
@private
	UIView						*_view;
}

NPP_SINGLETON_INTERFACE(NPPStatusBar);

@property (nonatomic, readonly) UIView *statusBarView;
@property (nonatomic) BOOL showRoundedCorner;
@property (nonatomic) BOOL hiddenInfo;
@property (nonatomic, NPP_RETAIN) UIColor *backgroundColor; // nil resets the iOS default.

@end