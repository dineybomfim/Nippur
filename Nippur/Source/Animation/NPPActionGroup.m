/*
 *	NPPActionGroup.m
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

#import "NPPActionGroup.h"

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

@implementation NPPActionGroup

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

- (void) setGroup:(NSArray *)actions
{
	NPPBlockAction actionBlock = nil;
	unsigned int count = (unsigned int)[actions count];
	__block __typeof__(self) bself = self;
	
	// Initializing the sub-actions array once.
	nppRelease(_subActions);
	_subActions = [[NSMutableArray alloc] initWithArray:actions];
	
	// Initializing the tracker dictionary.
	nppRelease(_tracker);
	_tracker = [[NSMutableDictionary alloc] init];
	
	actionBlock = ^(id currentTarget, float elapsedTime, double token)
	{
		NPPAction *action = nil;
		float actionDuration = 0.0f;
		NSString *address = nil;
		double *marks = calloc(count, NPP_SIZE_DOUBLE);
		double *marksPtr = marks;
		
		// Use the memory address' string as the dictionary key.
		address = [NSString stringWithFormat:@"%.16g", token];
		
		// Gets the marks values.
		// It's a C array, which is serialized as a single NSString separated by spaces:
		// @"n1 n2 n3..."
		nppSetCArrayString([bself->_tracker objectForKey:address], marks);
		
		// Loop through all subactions, ensuring at least one run for all actions.
		for (action in bself->_subActions)
		{
			// Gets the action final duration.
			actionDuration = action.finalDuration;
			
			// Initializes a new mark, if needed.
			if (*marksPtr == 0.0)
			{
				*marksPtr = nppGetActionToken();
			}
			
			// ACTION BLOCK
			// In group mode, the marks also helps to identify the finished actions.
			// Just finished actions have their mark as -1.0.
			if (elapsedTime < actionDuration)
			{
				// In case of changing the action duration, it can restart again.
				if (*marksPtr == -1.0)
				{
					*marksPtr = nppGetActionToken();
				}
				
				// Executing the block.
				nppBlock(action.actionBlock, currentTarget, elapsedTime, *marksPtr);
			}
			// The marks higher than ZERO means this action is not finished yet.
			else if (*marksPtr > 0.0)
			{
				// Executing the block for the last time.
				nppBlock(action.actionBlock, currentTarget, elapsedTime, *marksPtr);
				
				// Sets this action's mark as finished.
				*marksPtr = -1.0;
			}
			
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
		[self setGroup:actions];
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
	NPPActionGroup *copy = [super copyWithZone:zone];
	
	// Copying properties.
	[copy setGroup:_subActions];
	
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
	
	// Reversing all actions and their selves. For example: (1, 2, 3) becomes (1R, 2R, 3R).
	for (i = 0; i < length; ++i)
	{
		[reversedActions addObject:[[_subActions objectAtIndex:i] reversed]];
	}
	
	// Creating the new reversed action.
	NPPActionGroup *action = [[[self class] alloc] init];
	action.duration = _time.duration;
	action.speed = _time.speed;
	[action setGroup:reversedActions];
	
	return nppAutorelease(action);
}

- (float) finalDuration
{
	float value = 0.0f;
	NPPAction *action = nil;
	
	// Gets the highest duration.
	for (action in _subActions)
	{
		value = MAX(value, action.finalDuration);
	}
	
	return value;
}

- (NSString *) description
{
	NPPAction *action;
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