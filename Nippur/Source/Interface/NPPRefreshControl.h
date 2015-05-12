/*
 *	NPPRefreshControl.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/30/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"

typedef enum
{
	NPPRefreshControlTypeTop,
	NPPRefreshControlTypeBottom,
} NPPRefreshControlType;

@protocol NPPRefreshControlDelegate <NSObject>

@optional
/*!
 *					Called on delegates to instruct about the current dragging animation. You can also
 *					override this method in a subclass, in this case you should call super.
 *
 *	@param			percentage
 *					Indicates the current amount of the animation. Goes from 0.0 - 1.0, where 0.0 means
 *					the refresh view is closed and 1.0 means it's fully opened.
 */
- (void) draggingRefreshing:(float)percentage;

@end

@interface NPPRefreshControl : UIControl <NPPRefreshControlDelegate>
{
@private
	NPPRefreshControlType				_type;
	float								_refreshHeight;
	float								_percentage;
	BOOL								_refreshing;
	id <NPPRefreshControlDelegate>		_delegate;
	
	UIEdgeInsets						_edgeInsets;
}

@property (nonatomic) NPPRefreshControlType type;
@property (nonatomic) float refreshHeight; // Default is 70.0
@property (nonatomic, readonly) float percentage;
@property (nonatomic, readonly, getter = isRefreshing) BOOL refreshing;
@property (nonatomic, NPP_ASSIGN) id <NPPRefreshControlDelegate> delegate;

+ (instancetype) refreshTopWithTarget:(id)target action:(SEL)action;
+ (instancetype) refreshBottomWithTarget:(id)target action:(SEL)action;

- (void) beginRefreshing;
- (void) endRefreshing;

@end
