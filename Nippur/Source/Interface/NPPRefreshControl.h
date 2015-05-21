/*
 *	NPPRefreshControl.h
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com/nippur
 *	
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"

typedef NS_OPTIONS(NSUInteger, NPPRefreshControlType)
{
	NPPRefreshControlTypeTop,
	NPPRefreshControlTypeBottom,
};

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
