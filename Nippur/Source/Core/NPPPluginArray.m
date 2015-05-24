/*
 *	NPPPluginArray.m
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

#import "NPPPluginArray.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

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

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

#pragma mark -
#pragma mark NSArray Category
#pragma mark -
//**********************************************************************************************************
//
//	NSArray Category
//
//**********************************************************************************************************

@implementation NSArray(NPPArray)

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

- (void) performSelectorInAllItems:(SEL)selector
{
	
	NSUInteger i;
	NSUInteger length = [self count];
	id anObject;
	
	for (i = 0; i < length; ++i)
	{
		anObject = [self objectAtIndex:i];
		nppPerformAction(anObject, selector);
	}
}

- (id) mostRepeatedItem
{
	NSCountedSet *bag = [[NSCountedSet alloc] initWithArray:self];
	id mostOccurring = nil;
	id item = nil;
	NSUInteger highest = 0;
	
	for (item in bag)
	{
		if ([bag countForObject:item] > highest)
		{
			highest = [bag countForObject:item];
			mostOccurring = item;
		}
	}
	
	nppRelease(bag);
	
	return mostOccurring;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end

#pragma mark -
#pragma mark NSMutableArray Category
#pragma mark -
//**********************************************************************************************************
//
//	NSMutableArray Category
//
//**********************************************************************************************************

@implementation NSMutableArray(NPPArray)

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

- (void) addObjectOnce:(id)anObject
{
	if ([self indexOfObject:anObject] == NSNotFound)
	{
		[self addObject:anObject];
	}
}

- (void) addObjectsOnceFromArray:(NSArray *)otherArray
{
	NSUInteger i;
	NSUInteger length = [otherArray count];
	id anObject;
	
	for (i = 0; i < length; ++i)
	{
		anObject = [otherArray objectAtIndex:i];
		
		if ([self indexOfObject:anObject] == NSNotFound)
		{
			[self addObject:anObject];
		}
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end