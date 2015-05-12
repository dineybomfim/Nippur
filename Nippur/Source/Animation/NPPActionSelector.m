/*
 *	NPPActionSelector.m
 *	Nippur
 *
 *	The Nippur is a framework for iOS to make daily work easier and more reusable.
 *	This Nippur contains many API and includes many wrappers to other Apple frameworks.
 *
 *	More information at the official web site: http://db-in.com/nippur
 *
 *	Created by Diney Bomfim on 8/12/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPActionSelector.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPEncodeTarget	@"target"
#define kNPPEncodeSelector	@"selector"

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

@implementation NPPActionSelector

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

- (void) setTarget:(id)target selector:(SEL)selector
{
	NPPBlockAction actionBlock = nil;
	__block __typeof__(self) bself = self;
	
	nppRelease(_target);
	_target = nppRetain(target);
	_selector = selector;
	
	actionBlock = ^(id currentTarget, float elapsedTime, double token)
	{
		// The nil targets become the current target.
		id finalTarget = (bself->_target != nil) ? bself->_target : currentTarget;
		
		nppPerformAction(finalTarget, selector);
	};
	
	self.actionBlock = actionBlock;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

#pragma mark -
#pragma mark NSCoding
//*************************
//	NSCoding
//*************************

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSString *selector = [aDecoder decodeObjectForKey:kNPPEncodeSelector];
		id target = [aDecoder decodeObjectForKey:kNPPEncodeTarget];
		
		[self setTarget:target selector:NSSelectorFromString(selector)];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:NSStringFromSelector(_selector) forKey:kNPPEncodeSelector];
	if ([_target conformsToProtocol:@protocol(NSCoding)])
	{
		[aCoder encodeObject:_target forKey:kNPPEncodeTarget];
	}
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (float) finalDuration
{
	return 0.0f;
}

- (NSString *) description
{
	NSMutableString *string = [NSMutableString stringWithString:[super description]];
	
	[string appendFormat:@"{"];
	[string appendFormat:@" target: %@", _target];
	[string appendFormat:@" action: %@", NSStringFromSelector(_selector)];
	[string appendFormat:@" }"];
	
	return string;
}

- (void) dealloc
{
	nppRelease(_target);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end