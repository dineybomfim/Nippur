/*
 *	NPPStatusBar.m
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com
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

#import "NPPStatusBar.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_STATUS_VARIABLE			@"_statusBar"

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static UIView *nppStatusBarForeground(NSArray *subviews)
{
	Class foregroundClass = NSClassFromString(@"UIStatusBarForegroundView");
	UIView *item = nil;
	
	for (item in subviews)
	{
		if ([item isKindOfClass:foregroundClass])
		{
			return item;
		}
	}
	
	return nil;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPStatusBar

NPP_SINGLETON_IMPLEMENTATION(NPPStatusBar);

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic statusBarView, showRoundedCorner, backgroundColor;

- (UIView *) statusBarView
{
	if (_view == nil)
	{
		// Does not need to retain, as the status bar is unique and
		// is retained by the singleton "sharedApplication".
		_view = [[UIApplication sharedApplication] valueForKey:NPP_STATUS_VARIABLE];
		
		NSArray *subviews = [_view subviews];
		UIView *vBackground = nil;
		UIView *vForeground = nil;
		
		if ([subviews count] >= 2)
		{
			vBackground = [subviews objectAtIndex:0];
			vForeground = [subviews objectAtIndex:1];
		}
		
		_view.opaque = NO;
		
		// ATTENTION: this is the layer where the iOS status goes on, like "hotspot alert" and "calls".
		// Use it respectfully.
		vBackground.layer.contents = nil;
		
		vForeground.opaque = NO;
		vForeground.backgroundColor = [UIColor clearColor];
	}
	
	return _view;
}

- (BOOL) showRoundedCorner
{
	UIView *statusBarView = self.statusBarView;
	NSArray *subviews = [[statusBarView superview] subviews];
	UIView *topCorner = nil;
	UIView *bottomCorner = nil;
	
	// Avoiding out of bounds. It can happen when there is no rounded corner.
	if ([subviews count] >= 3)
	{
		topCorner = [subviews objectAtIndex:1];
		bottomCorner = [subviews objectAtIndex:2];
	}
	
	return (![topCorner isHidden] && [topCorner alpha] == 1.0f && [bottomCorner alpha] == 1.0f);
}

- (void) setShowRoundedCorner:(BOOL)value
{
	UIView *statusBarView = self.statusBarView;
	NSArray *subviews = [[statusBarView superview] subviews];
	UIView *topCorner = nil;
	UIView *bottomCorner = nil;
	
	// Avoiding out of bounds. It can happen when there is no rounded corner.
	if ([subviews count] >= 3)
	{
		topCorner = [subviews objectAtIndex:1];
		bottomCorner = [subviews objectAtIndex:2];
	}
	
	topCorner.alpha = (float)value;
	bottomCorner.alpha = (float)value;
	topCorner.hidden = !value;
	bottomCorner.hidden = !value;
}

- (BOOL) hiddenInfo { return nppStatusBarForeground(self.statusBarView.subviews).hidden; }
- (void) setHiddenInfo:(BOOL)value
{
	UIView *statusBarView = self.statusBarView;
	UIView *foreground = nppStatusBarForeground(statusBarView.subviews);
	foreground.hidden = value;
	statusBarView.userInteractionEnabled = !value;
}

- (UIColor *) backgroundColor { return self.statusBarView.backgroundColor; }
- (void) setBackgroundColor:(UIColor *)value
{
	UIView *statusBarView = self.statusBarView;
	
	if (value == nil)
	{
		value = (nppDeviceOSVersion() >= 7.0f) ? [UIColor clearColor] : [UIColor blackColor];
	}
	
	statusBarView.backgroundColor = value;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
