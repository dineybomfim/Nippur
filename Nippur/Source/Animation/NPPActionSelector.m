/*
 *	NPPActionSelector.m
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