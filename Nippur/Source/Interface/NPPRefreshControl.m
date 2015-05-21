/*
 *	NPPTableViewPuller.m
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

#import "NPPRefreshControl.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_REFRESH_AREA		70.0f
#define nppRefreshView(v)		((UIScrollView *)(([(v) isKindOfClass:[UIScrollView class]]) ? (v) : nil))

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

@interface NPPRefreshControl() <UIGestureRecognizerDelegate>

// Initializes a new instance.
- (void) initializingRefresh;

- (void) handlePan:(UIPanGestureRecognizer *)gesture;
- (void) updatePercentage:(float)percentage;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPRefreshControl

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize refreshHeight = _refreshHeight;
@synthesize percentage = _percentage;
@synthesize refreshing = _refreshing;
@synthesize delegate = _delegate;

@dynamic type;

- (NPPRefreshControlType) type { return _type; }
- (void) setType:(NPPRefreshControlType)value
{
	if (!_refreshing)
	{
		_type = value;
	}
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializingRefresh];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializingRefresh];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializingRefresh];
	}
	
	return self;
}

+ (instancetype) refreshTopWithTarget:(id)target action:(SEL)action
{
	NPPRefreshControl *control = [[self alloc] init];
	
	[control addTarget:target action:action forControlEvents:UIControlEventValueChanged];
	
	return nppAutorelease(control);
}

+ (instancetype) refreshBottomWithTarget:(id)target action:(SEL)action
{
	NPPRefreshControl *control = [[self alloc] init];
	
	[control setType:NPPRefreshControlTypeBottom];
	[control addTarget:target action:action forControlEvents:UIControlEventValueChanged];
	
	return nppAutorelease(control);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializingRefresh
{
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.backgroundColor = nil;
	self.opaque = NO;
	self.clipsToBounds = YES;
	self.refreshHeight = NPP_REFRESH_AREA;
}

- (void) handlePan:(UIPanGestureRecognizer *)gesture
{
	UIGestureRecognizerState state = gesture.state;
	UIScrollView *scrollView = nppRefreshView(self.superview);
	float delta = 0.0f;
	float percentage = 0.0f;
	
	// Dealing with all types.
	switch (_type)
	{
		case NPPRefreshControlTypeBottom:
			delta = scrollView.contentSize.height - scrollView.frame.size.height;
			delta -= scrollView.contentOffset.y + _edgeInsets.bottom;
			delta *= -1.0f;
			break;
		case NPPRefreshControlTypeTop:
		default:
			delta = scrollView.contentOffset.y + _edgeInsets.top;
			delta *= -1.0f;
			break;
	}
	
	percentage = delta / _refreshHeight;
	percentage = NPPClamp(percentage, 0.0f, 100.0f);
	
	switch (state)
	{
		case UIGestureRecognizerStateBegan:
			if (!_refreshing)
			{
				_edgeInsets = scrollView.contentInset;
			}
			break;
		case UIGestureRecognizerStateChanged:
			if (percentage != _percentage)
			{
				[self updatePercentage:percentage];
				[self draggingRefreshing:percentage];
			}
			break;
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			if (percentage >= 1.0f)
			{
				[self beginRefreshing];
			}
			else
			{
				[self endRefreshing];
			}
			break;
		default:
			break;
	}
}

- (void) updatePercentage:(float)percentage
{
	CGRect frame = super.frame;
	UIScrollView *scrollView = nppRefreshView(self.superview);
	
	// Dealing with all types.
	switch (_type)
	{
		case NPPRefreshControlTypeBottom:
			frame.origin.y = scrollView.contentSize.height;
			frame.size.height = percentage * _refreshHeight;
			break;
		case NPPRefreshControlTypeTop:
		default:
			frame.origin.y = -percentage * _refreshHeight;
			frame.size.height = percentage * _refreshHeight;
			break;
	}
	
	super.frame = frame;
	_percentage = percentage;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) draggingRefreshing:(float)percentage
{
	nppPerformAction(_delegate, @selector(draggingRefreshing:));
}

- (void) beginRefreshing
{
	if (!_refreshing)
	{
		UIScrollView *scrollView = nppRefreshView(self.superview);
		UIEdgeInsets edge = _edgeInsets;
		
		// Dealing with all types.
		switch (_type)
		{
			case NPPRefreshControlTypeBottom:
				edge.bottom += _refreshHeight;
				break;
			case NPPRefreshControlTypeTop:
			default:
				edge.top += _refreshHeight;
				break;
		}
		
		_refreshing = YES;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kNPPAnimTime];
		scrollView.contentInset = edge;
		[self updatePercentage:1.0f];
		[UIView commitAnimations];
		
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (void) endRefreshing
{
	if (_refreshing || _percentage > 0.0f)
	{
		UIScrollView *scrollView = nppRefreshView(self.superview);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kNPPAnimTime];
		scrollView.contentInset = _edgeInsets;
		[self updatePercentage:0.0f];
		[UIView commitAnimations];
		
		_refreshing = NO;
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) didMoveToSuperview
{
	[super didMoveToSuperview];
	
	UIPanGestureRecognizer *gesture = nil;
	UIView *superView = nppRefreshView(self.superview);
	
	super.frame = CGRectMake(0.0f, 0.0f, superView.frame.size.width, 0.0f);
	
	//*
	gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	gesture.delegate = self;
	[superView addGestureRecognizer:gesture];
	nppRelease(gesture);
	/*/
	NSArray *array = [superView gestureRecognizers];
	
	for (gesture in array)
	{
		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			[gesture addTarget:self action:@selector(handlePan:)];
		}
	}
	//*/
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void) dealloc
{
	self.delegate = nil;
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
