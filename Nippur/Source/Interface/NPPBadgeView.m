/*
 *	NPPBadgeView.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/18/12.
 *	Copyright 2012 db-in. All rights reserved.
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
