/*
 *	NPPModelVO.m
 *	Nippur
 *	v1.0
 *
 *	Created by Diney Bomfim on 4/25/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPModelVO.h"

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

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

@implementation NPPModelVO

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

- (id) initWithData:(id)data
{
	if ((self = [super init]))
	{
		[self updateWithData:data];
	}
	
	return self;
}

+ (id) modelWithData:(id)data
{
	NPPModelVO *modelVO = [[self alloc] initWithData:data];
	
	return nppAutorelease(modelVO);
}

+ (id) modelFromFile:(NSString *)fileName folder:(NPPDataFolder)folder
{
	NPPModelVO *model = nil;
	id object = [NPPDataManager loadLocal:fileName type:NPPDataTypeArchive folder:folder];
	
	// Updating the model from the loaded file, if it's valid.
	if ([object isKindOfClass:self])
	{
		model = object;
	}
	
	return model;
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
#pragma mark NPPJSONSource
//*************************
//	NPPJSONSource
//*************************

- (id) dataForJSON
{
	return nil;
}

#pragma mark -
#pragma mark NSCoding
//*************************
//	NSCoding
//*************************

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init]))
	{
		[self updateWithData:[NPPJSON objectWithData:[aDecoder decodeDataObject]]];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeDataObject:[NPPJSON dataWithObject:[self dataForJSON]]];
}

#pragma mark -
#pragma mark NSCopying
//*************************
//	NSCopying
//*************************

- (id) copyWithZone:(NSZone *)zone
{
	NPPModelVO *copy = [[[self class] allocWithZone:zone] init];
	
	// Copying properties.
	/*
	[copy updateWithData:[self dataForJSON]];
	/*/
	NSString *json = [NPPJSON stringWithObject:[self dataForJSON]];
	[copy updateWithData:[NPPJSON objectWithString:json]];
	//*/
	
	return copy;
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (void) updateWithData:(id)data
{
	// Does nothing here, just to override.
}

- (BOOL) checkCompatibility:(id *)dataPointer checkClass:(Class)aClass
{
	BOOL result = YES;
	
	if (![*dataPointer isKindOfClass:aClass])
	{
		if ([*dataPointer respondsToSelector:@selector(dataForJSON)])
		{
			*dataPointer = [*dataPointer dataForJSON];
		}
		else
		{
			result = NO;
		}
	}
	
	return result;
}

- (void) saveToFile:(NSString *)fileName folder:(NPPDataFolder)folder
{
	[NPPDataManager saveLocal:self name:fileName type:NPPDataTypeArchive folder:folder];
}

- (void) loadFromFile:(NSString *)fileName folder:(NPPDataFolder)folder
{
	id object = [NPPDataManager loadLocal:fileName type:NPPDataTypeArchive folder:folder];
	
	// Updating the model from the loaded file, if it's valid.
	if ([object isKindOfClass:[self class]])
	{
		[self updateWithData:[NPPJSON objectWithString:[object description]]];
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	return [NPPJSON stringWithObject:[self dataForJSON]];
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
