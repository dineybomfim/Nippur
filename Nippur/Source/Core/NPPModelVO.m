/*
 *	NPPModelVO.m
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

- (id) initWithJSONObject:(id)data
{
	if ((self = [super init]))
	{
		[self decodeJSONObject:data];
	}
	
	return self;
}

+ (id) modelWithJSONObject:(id)data
{
	NPPModelVO *modelVO = [[self alloc] initWithJSONObject:data];
	
	return nppAutorelease(modelVO);
}

+ (id) modelFromFile:(NSString *)fileName folder:(NPPDataFolder)folder
{
	NPPModelVO *model = nil;
	id object = [NPPDataManager loadFile:fileName type:NPPDataTypeArchive folder:folder];
	
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
#pragma mark NSCoding
//*************************
//	NSCoding
//*************************

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init]))
	{
		[self decodeJSONObject:[NPPJSON objectWithData:[aDecoder decodeDataObject]]];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeDataObject:[NPPJSON dataWithObject:[self encodeJSONObject]]];
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
	NSString *json = [NPPJSON stringWithObject:[self encodeJSONObject]];
	[copy decodeJSONObject:[NPPJSON objectWithString:json]];
	
	return copy;
}

#pragma mark -
#pragma mark IBMJSONSource
//*************************
//	IBMJSONSource
//*************************

- (void) decodeJSONObject:(id)data
{
	// Does nothing here, just to override.
}

- (id) encodeJSONObject
{
	return nil;
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (BOOL) checkCompatibility:(id *)dataPointer checkClass:(Class)aClass
{
	BOOL result = YES;
	
	if (![*dataPointer isKindOfClass:aClass])
	{
		if ([*dataPointer respondsToSelector:@selector(encodeJSONObject)])
		{
			*dataPointer = [*dataPointer encodeJSONObject];
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
	[NPPDataManager saveFile:self name:fileName type:NPPDataTypeArchive folder:folder];
}

- (void) loadFromFile:(NSString *)fileName folder:(NPPDataFolder)folder
{
	id object = [NPPDataManager loadFile:fileName type:NPPDataTypeArchive folder:folder];
	
	// Updating the model from the loaded file, if it's valid.
	if ([object isKindOfClass:[self class]])
	{
		[self decodeJSONObject:[NPPJSON objectWithString:[object description]]];
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	return [NPPJSON stringWithObject:[self encodeJSONObject]];
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
