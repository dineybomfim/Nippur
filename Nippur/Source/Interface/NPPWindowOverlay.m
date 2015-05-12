/*
 *	NPPWindowOverlay.m
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

#import "NPPWindowOverlay.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_WINDOW_KEY_ANIM			@"NPPKeyWindowAnim"

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

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPWindowOverlay()

// Initializes a new instance.
- (void) initializing;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPWindowOverlay

NPP_SINGLETON_IMPLEMENTATION(NPPWindowOverlay);

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic backgroundView;

- (UIView *) backgroundView { return [[_viBackground subviews] firstObject]; }
- (void) setBackgroundView:(UIView *)view
{
	if (view == nil)
	{
		UIColor *startColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		UIColor *endColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9f];
		UIImage *backgroundImage = [UIImage imageWithRadialGradient:self.view.size
															  start:startColor
																end:endColor];
		UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
		backgroundView.contentMode = UIViewContentModeScaleToFill;
		backgroundView.autoresizingMask = NPPAutoresizingAll;
		backgroundView.frame = self.view.frame;
		backgroundView.opaque = NO;
		
		view = backgroundView;
		
		nppAutorelease(backgroundView);
	}
	
	[_viBackground removeAllSubviews];
	[_viBackground addSubview:view];
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self initializing];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	UIView *selfView = self.view;
	CGRect bounds = nppDeviceScreenRectOriented(NO);
	bounds.origin = CGPointZero;
	
	selfView.frame = bounds;
	
	_children = [[NSMutableArray alloc] init];
	
	//*************************
	//	View Hierarchy
	//*************************
	
	// Creating the window.
	_window = [[NPPWindow alloc] initWithFrame:bounds];
	_window.avoidKeyWindow = YES;
	_window.windowLevel = UIWindowLevelStatusBar;
	_window.rootViewController = self;
	
	// Creating the background holder.
	_viBackground = [[UIView alloc] initWithFrame:bounds];
	_viBackground.autoresizingMask = NPPAutoresizingAll;
	_viBackground.alpha = 0.0f;
	
	// Creating the subviews holder.
	_viHolder = [[UIView alloc] initWithFrame:bounds];
	_viHolder.autoresizingMask = NPPAutoresizingAll;
	
	// The default gradient background view.
	[self setBackgroundView:nil];
	[selfView addSubview:_viBackground];
	[selfView addSubview:_viHolder];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addView:(UIView *)view
{
	// This order is important, because if the last object is equal to the new object, nothing will change.
	[[[_viHolder subviews] lastObject] setUserInteractionEnabled:NO];
	[view setUserInteractionEnabled:YES];
	[_children addObject:view];
	[_viHolder addSubview:view];
	
	// Showing the window.
	_window.hidden = NO;
	[_viBackground runAction:[NPPAction fadeIn] withKey:NPP_WINDOW_KEY_ANIM];
}

- (void) removeView:(UIView *)view
{
	unsigned int count = (unsigned int)[[_viHolder subviews] count];
	
	NPPBlockVoid block = ^(void)
	{
		NSArray *subviews = nil;
		NSUInteger index = [_children indexOfObjectIdenticalTo:view];
		
		if (index != NSNotFound)
		{
			[_children removeObjectAtIndex:index];
			index = [_children indexOfObjectIdenticalTo:view];
		}
		
		// If there is no more count reference for this view, remove it.
		if (index == NSNotFound)
		{
			// Removing the view and gets back the remaining subviews.
			[view removeFromSuperview];
			subviews = [_viHolder subviews];
			
			// If that was the last one, hides the over window as well.
			if ([subviews count] == 0)
			{
				_window.hidden = YES;
			}
		}
		else
		{
			subviews = [_viHolder subviews];
		}
		
		// If there are other views, enables the interaction in the next one.
		[[subviews lastObject] setUserInteractionEnabled:YES];
	};
	
	// Waiting for the children animation. If there is no more children, run the fade out animation.
	if (count <= 1)
	{
		NPPAction *wait = [NPPAction waitForDuration:kNPPAnimTime];
		NPPAction *sequence = [NPPAction sequence:@[ wait, [NPPAction fadeOut] ]];
		
		[_viBackground runAction:sequence withKey:NPP_WINDOW_KEY_ANIM];
		[_viBackground runAction:[NPPAction waitForDuration:kNPPAnimTimeX2] completion:block];
	}
	else
	{
		[_viBackground runAction:[NPPAction waitForDuration:kNPPAnimTime] completion:block];
	}
}

- (unsigned int) viewsCount
{
	return (unsigned int)[[[self view] subviews] count];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (BOOL) shouldAutorotate
{
	return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void) dealloc
{
	nppRelease(_children);
	nppRelease(_viBackground);
	nppRelease(_viHolder);
	nppRelease(_window);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
