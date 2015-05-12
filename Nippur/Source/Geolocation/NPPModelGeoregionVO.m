/*
 *	NPPModelGeoregionVO.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 5/31/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPModelGeoregionVO.h"

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

@implementation NPPModelGeoregionVO

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize name = _name, center = _center, radius = _radius;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

+ (id) modelWithName:(NSString *)name center:(NPPModelGeolocationVO *)geolocation radius:(double)radius
{
	NPPModelGeoregionVO *modelVO = [[self alloc] init];
	modelVO.name = name;
	modelVO.center = geolocation;
	modelVO.radius = radius;
	
	return nppAutorelease(modelVO);
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

- (void) updateWithData:(id)data
{
	// Avoids invalid data formats.
	if (![self checkCompatibility:&data checkClass:[NSDictionary class]])
	{
		return;
	}
	
	// Example:
	// {name:reference,center:<geolocation>,radius:123.456}
	
	self.name = [data objectForKey:@"name"];
	self.center = [NPPModelGeolocationVO modelWithData:[data objectForKey:@"center"]];
	self.radius = [[data objectForKey:@"radius"] doubleValue];
}

- (id) dataForJSON
{
	NSString *radius = (_radius != 0.0) ? [NSString stringWithFormat:@"%.16g", _radius] : nil;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	nppDictionaryAdd(_name, @"name", dict);
	nppDictionaryAdd(_center, @"center", dict);
	nppDictionaryAdd(radius, @"radius", dict);
	
	return dict;
}

- (BOOL) isEqual:(id)object
{
	BOOL result = NO;
	
	// Use class directly instead of "self", because it compare subclasses as well.
	if ([object isKindOfClass:[NPPModelGeoregionVO class]])
	{
		NPPModelGeoregionVO *region = object;
		result = ([_center isEqual:[region center]]) && (_radius == [region radius]);
	}
	
	return result;
}

- (void) dealloc
{
	nppRelease(_name);
	nppRelease(_center);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
