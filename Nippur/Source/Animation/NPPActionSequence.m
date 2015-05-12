/*
 *	NPPActionSequence.m
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

#import "NPPActionSequence.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPEncodeActions	@"subActions"

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

@implementation NPPActionSequence

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

- (void) setSequence:(NSArray *)actions
{
	NPPBlockAction actionBlock = nil;
	unsigned int count = (unsigned int)[actions count];
	__block __typeof__(self) bself = self;
	
	// Initializing the sub-actions array.
	nppRelease(_subActions);
	_subActions = [[NSMutableArray alloc] initWithArray:actions];
	
	// Initializing the tracker dictionary.
	nppRelease(_tracker);
	_tracker = [[NSMutableDictionary alloc] init];
	
	actionBlock = ^(id currentTarget, float elapsedTime, double token)
	{
		NPPAction *action = nil;
		float actionDuration = 0.0f;
		float totalDuration = 0.0f;
		NSString *address = nil;
		double *marks = calloc(count, NPP_SIZE_DOUBLE);
		double *marksPtr = marks;
		
		// Use the memory address' string as the dictionary key.
		address = [NSString stringWithFormat:@"%.16g", token];
		
		// Gets the marks values.
		// It's a C array, which is serialized as a single NSString separated by spaces:
		// @"n1 n2 n3..."
		nppSetCArrayString([bself->_tracker objectForKey:address], marks);
		
		// Looping through actions, one by one.
		for (action in actions)
		{
			// Gets the action final duration.
			actionDuration = action.finalDuration;
			
			// Initializes a new mark, if needed.
			if (*marksPtr == 0.0)
			{
				*marksPtr = nppGetActionToken();
			}
			
			// ACTION BLOCK
			// In sequence mode, the marks also helps to identify the finished actions.
			// Just finished actions have their mark as -1.0.
			if (elapsedTime < actionDuration + totalDuration)
			{
				// In case of changing the action duration, it can restart again.
				if (*marksPtr == -1.0)
				{
					*marksPtr = nppGetActionToken();
				}
				
				// Executing the block.
				nppBlock(action.actionBlock, currentTarget, elapsedTime - totalDuration, *marksPtr);
				break;
			}
			// The marks higher than ZERO means this action is not finished yet.
			else if (*marksPtr > 0.0)
			{
				// Executing the block for the last time.
				nppBlock(action.actionBlock, currentTarget, elapsedTime - totalDuration, *marksPtr);
				
				// Sets this action's mark as finished.
				*marksPtr = -1.0;
			}
			
			totalDuration += actionDuration;
			++marksPtr;
		}
		
		[bself->_tracker setObject:nppGetCArrayString(marks, count) forKey:address];
		
		nppFree(marks);
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
		NSArray *actions = [aDecoder decodeObjectForKey:kNPPEncodeActions];
		[self setSequence:actions];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:_subActions forKey:kNPPEncodeActions];
}

#pragma mark -
#pragma mark NSCopying
//*************************
//	NSCopying
//*************************

- (id) copyWithZone:(NSZone *)zone
{
	NPPActionSequence *copy = [super copyWithZone:zone];
	
	// Copying properties.
	[copy setSequence:_subActions];
	
	return copy;
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (NPPAction *) reversed
{
	unsigned int i = 0;
	unsigned int length = (unsigned int)[_subActions count];
	NSMutableArray *reversedActions = [NSMutableArray array];
	
	// Reversing all actions and their selves. For example: (1, 2, 3) becomes (3R, 2R, 1R).
	for (i = length; i > 0; --i)
	{
		[reversedActions addObject:[[_subActions objectAtIndex:i - 1] reversed]];
	}
	
	// Creating the new reversed action.
	NPPActionSequence *action = [[[self class] alloc] init];
	action.duration = _time.duration;
	action.speed = _time.speed;
	[action setSequence:_subActions];
	
	return nppAutorelease(action);
}

- (float) finalDuration
{
	float value = 0.0f;
	NPPAction *action = nil;
	
	// Sums all the subdurations.
	for (action in _subActions)
	{
		value += action.finalDuration;
	}
	
	return value;
}

- (NSString *) description
{
	NPPAction *action = nil;
	NSMutableString *string = [NSMutableString stringWithString:[super description]];
	
	[string appendFormat:@"\n("];
	
	for (action in _subActions)
	{
		[string appendFormat:@"\n	%@", [action description]];
	}
	
	[string appendString:@"\n)"];
	
	return string;
}

- (void) dealloc
{
	nppRelease(_subActions);
	nppRelease(_tracker);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end