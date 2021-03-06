/*
 *	NPPBadgeView.m
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

#import "NPPBadgeView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_BADGE_BG			@"npp_badge.png"

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

@interface NPPBadgeView()

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

@implementation NPPBadgeView

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic number;

- (int) number { return [[_labelNumber text] intValue]; }
- (void) setNumber:(int)value
{
	// New text label.
	_labelNumber.text = [NSString stringWithFormat:@"%i",value];
	[_labelNumber sizeToFit];
	
	// Adjusting the background size.
	_background.width = MAX(_background.image.size.width, _labelNumber.width + 25.0f);
	
	// Centering the text again.
	[_labelNumber centerInView:_background];
	
	self.size = _background.size;
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

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithNumber:(int)value
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializing];
		self.number = value;
	}
	
	return self;
}

+ (id) badgeWithNumber:(int)value
{
	NPPBadgeView *badge = [[NPPBadgeView alloc] initWithNumber:value];
	
	return nppAutorelease(badge);
}

+ (id) badgeWithApplicationBadgeNumber
{
	NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
	NPPBadgeView *badge = nil;
	
	if (badgeNumber > 0)
	{
		badge = [[NPPBadgeView alloc] initWithNumber:(int)badgeNumber];
	}
	
	return nppAutorelease(badge);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	self.userInteractionEnabled = NO;
	
	//*************************
	//	View Hierarchy
	//*************************
	
	nppRelease(_background);
	UIImage *background = nppImageFromFile(NPP_BADGE_BG);
	_background = [[UIImageView alloc] initWithImage:[background imageNineSliced]];
	
	nppRelease(_labelNumber);
	UIFont *font = [UIFont nppFontRegularWithSize:14.0f];
	_labelNumber = [[NPPLabel alloc] initWithCenterString:@"0" font:font maxWidth:_background.width];
	_labelNumber.numberOfLines = 1;
	[_labelNumber centerInView:_background];
	
	self.frame = _background.frame;
	
	[self addSubview:_background];
	[self addSubview:_labelNumber];
	
	//*************************
	//	Actions / Gestures
	//*************************
}

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
	nppRelease(_background);
	nppRelease(_labelNumber);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
