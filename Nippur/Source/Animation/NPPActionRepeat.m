/*
 *	NPPActionRepeat.m
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

#import "NPPActionRepeat.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPEncodeAction	@"action"
#define kNPPEncodeCount		@"count"

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

@implementation NPPActionRepeat

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize count = _count;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (void) setRepeatAction:(NPPAction *)action count:(unsigned int)repeatCount
{
	NPPBlockAction actionBlock = nil;
	__block __typeof__(self) bself = self;
	
	nppRelease(_action);
	_action =  nppRetain(action);
	_count = (repeatCount == NPP_MAX_32) ? NPP_MAX_32 - 1 : repeatCount;
	
	// Initializing the tracker dictionary.
	nppRelease(_tracker);
	_tracker = [[NSMutableDictionary alloc] init];
	
	actionBlock = ^(id currentTarget, float elapsedTime, double token)
	{
		float actionDuration = action.finalDuration;
		unsigned int currentLoop = 0;
		NSString *address = nil;
		double *marks = calloc(2, NPP_SIZE_DOUBLE);
		
		// Use the memory address' string as the dictionary key.
		address = [NSString stringWithFormat:@"%.16g", token];
		
		// Gets the marks values.
		// It's a C array, which is serialized as a single NSString separated by spaces:
		// @"n1 n2 n3..."
		nppSetCArrayString([bself->_tracker objectForKey:address], marks);
		
		// There is a special move for instantaneous actions (ZERO duration).
		// Repeating such action will not perform all loop at once, instead, each loop will be
		// executed at each timer cycle. To do so, the action duration becomes a timer cycle, not ZERO.
		actionDuration = (actionDuration > 0.0f) ? actionDuration : NPP_CYCLE;
		
		// Finding the current loop.
		currentLoop = (unsigned int)floorf(elapsedTime / actionDuration);
		
		// First run.
		if (marks[1] == 0.0)
		{
			marks[0] = currentLoop;
			marks[1] = nppGetActionToken();
		}
		
		// Changing the loop.
		if (currentLoop != marks[0])
		{
			// Executing the block.
			nppBlock(action.actionBlock, currentTarget, elapsedTime, marks[1]);
			
			marks[0] = currentLoop;
			marks[1] = nppGetActionToken();
		}
		else
		{
			// The elapsed time is always related to the current loop.
			elapsedTime -= (actionDuration * currentLoop);
			
			// Executing the block.
			nppBlock(action.actionBlock, currentTarget, elapsedTime, marks[1]);
		}
		
		[bself->_tracker setObject:nppGetCArrayString(marks, 2) forKey:address];
		
		nppFree(marks);
	};
	
	self.actionBlock = actionBlock;
}

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

#pragma mark -
#pragma mark NSCoding
//*************************
//	NSCoding
//*************************

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NPPAction *action = [aDecoder decodeObjectForKey:kNPPEncodeAction];
		unsigned int count = [aDecoder decodeIntForKey:kNPPEncodeCount];
		
		[self setRepeatAction:action count:count];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:_action forKey:kNPPEncodeAction];
	[aCoder encodeInt:_count forKey:kNPPEncodeCount];
}

#pragma mark -
#pragma mark NSCopying
//*************************
//	NSCopying
//*************************

- (id) copyWithZone:(NSZone *)zone
{
	NPPActionRepeat *copy = [super copyWithZone:zone];
	
	// Copying properties.
	[copy setRepeatAction:_action count:_count];
	
	return copy;
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (NPPAction *) reversed
{
	// Creating the new reversed action.
	NPPActionRepeat *action = [[[self class] alloc] init];
	action.duration = _time.duration;
	action.speed = _time.speed;
	[action setRepeatAction:[_action reversed] count:_count];
	
	return nppAutorelease(action);
}

- (float) finalDuration
{
	float actionDuration = _action.finalDuration;
	
	// The +1 is added because the action will run at least once and then start repeating.
	// For instantaneous actions, the minimum cycle is taken instead of ZERO.
	actionDuration = ((actionDuration > 0.0f) ? actionDuration * (_count + 1) : NPP_CYCLE * _count);
	
	return actionDuration;
}

- (NSString *) description
{
	NSMutableString *string = [NSMutableString stringWithString:[super description]];
	
	[string appendFormat:@"{"];
	[string appendFormat:@" count: %u", _count];
	[string appendFormat:@" action: %@", _action];
	[string appendFormat:@" }"];
	
	return string;
}

- (void) dealloc
{
	nppRelease(_action);
	nppRelease(_tracker);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end