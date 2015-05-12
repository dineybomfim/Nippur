/*
 *	NPPArray+NSArray.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/9/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPArray+NSArray.h"

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