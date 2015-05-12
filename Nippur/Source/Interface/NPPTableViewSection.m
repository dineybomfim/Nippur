/*
 *	NPPTableViewSection.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 10/25/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPTableViewSection.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_SECTION_HEIGHT			30.0f

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

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPTableViewSection

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

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

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	[self viewDidInit];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) viewDidInit
{
	// Does nothing here, just in subclasses.
}

- (void) viewDidLoad
{
	// Does nothing here, just in subclasses.
}

+ (float) heightForItem
{
	return NPP_SECTION_HEIGHT;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (!_onTable)
	{
		_onTable = YES;
		[self viewDidLoad];
	}
}

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
