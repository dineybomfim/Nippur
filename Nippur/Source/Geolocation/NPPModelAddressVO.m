/*
 *	NPPModelAddressVO.m
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

#import "NPPModelAddressVO.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPREGEX_CLEAN_STREET			@"\\d*\\-*\\d+?( |$)"
#define kNPPREGEX_CLEAN_NUMBER			@".*?(\\d*\\-*\\d+?( |$)).*"
#define kNPPREGEX_CLEAN_DIVISION		@" (\\–|\\-) "
#define kNPPREGEX_CLEAN_COMMAS			@"( *, *)"

NSString *const kNPPAddressName			= @"<name>";
NSString *const kNPPAddressLine1		= @"<line1>";
NSString *const kNPPAddressLine2		= @"<line2>";
NSString *const kNPPAddressNeighborhood = @"<neighborhood>";
NSString *const kNPPAddressCity			= @"<city>";
NSString *const kNPPAddressState		= @"<state>";
NSString *const kNPPAddressCountry		= @"<country>";
NSString *const kNPPAddressShort		= @"<line1>, <line2>";
NSString *const kNPPAddressFull			= @"<line1>, <line2> - <neighborhood>, <city>/<state> - <country>";
NSString *const kNPPAddressPolitical	= @"<neighborhood>, <city>";

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

static NSString *_defaultShortFormat = nil;
static NSString *_defaultFullFormat = nil;
static NSString *_defaultPoliticalFormat = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

@interface NPPModelAddressVO()

- (NSString *) formatedAddress:(NSString *)format;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPModelAddressVO

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize tag = _tag, mode = _mode, date = _date, identifier = _identifier, name = _name,
			postalCode = _postalCode, line1 = _line1, line2 = _line2, neighborhood = _neighborhood,
			city = _city, state = _state, country = _country, geolocation = _geolocation;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (void) setMode:(int)mode
{
	_mode = mode;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (NSString *) formatedAddress:(NSString *)format
{
	NSMutableString *final = [[NSMutableString alloc] initWithString:format];
	NSRange range = NPPRangeZero;
	NSString *none = @"";
	//*
	range = [final rangeOfString:kNPPAddressName];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_name.length > 0) ? _name : none];
	}
	
	range = [final rangeOfString:kNPPAddressLine1];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_line1.length > 0) ? _line1 : none];
	}
	
	range = [final rangeOfString:kNPPAddressLine2];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_line2.length > 0) ? _line2 : none];
	}
	
	range = [final rangeOfString:kNPPAddressNeighborhood];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_neighborhood.length > 0) ? _neighborhood : none];
	}
	
	range = [final rangeOfString:kNPPAddressCity];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_city.length > 0) ? _city : none];
	}
	
	range = [final rangeOfString:kNPPAddressState];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_state.length > 0) ? _state : none];
	}
	
	range = [final rangeOfString:kNPPAddressCountry];
	if (range.length > 0)
	{
		[final replaceCharactersInRange:range withString:(_country.name.length > 0) ? _country.name : none];
	}
	/*/
	NSString *propertyName = nil;
	NSString *property = nil;
	
	do
	{
		range = nppRegExRangeOfMatch(format, @"\\<.*?\\>", NPPRegExFlagGDMI);
		propertyName = [format substringWithRange:range];
		property = [self valueForKey:propertyName];
		[final replaceCharactersInRange:range withString:(property.length > 0) ? property : none];
	}
	while (range.length > 0);
	//*/
	return nppAutorelease(final);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (NSString *) shortAddress
{
	return [self formatedAddress:_defaultShortFormat];
}

- (NSString *) fullAddress
{
	return [self formatedAddress:_defaultFullFormat];
}

- (NSString *) politicalAddress
{
	return [self formatedAddress:_defaultPoliticalFormat];
}

- (void) updateWithFormatedAddress:(NSString *)address overriding:(BOOL)override
{
	/*
	address = nppRegExReplace(address, kNPPREGEX_CLEAN_DIVISION, @",", NPPRegExFlagGDMI);
	address = nppRegExReplace(address, kNPPREGEX_CLEAN_COMMAS, @",", NPPRegExFlagGDMI);
	
	NSArray *components = [address componentsSeparatedByString:@","];
	NSString *part = [components firstObject];
	
	if ([part isEqualToString:_name])
	{
		
	}
	else if ([part isEqualToString:_line1])
	{
		
	}
	else if ([part isEqualToString:_line2])
	{
		
	}
	else if ([part isEqualToString:_neighborhood])
	{
		
	}
	else if ([part isEqualToString:_city])
	{
		
	}
	else if ([part isEqualToString:_state])
	{
		
	}
	else if ([part isEqualToString:_postalCode])
	{
		
	}
	/*/
	address = nppRegExReplace(address, kNPPREGEX_CLEAN_DIVISION, @",", NPPRegExFlagGDMI);
	address = nppRegExReplace(address, kNPPREGEX_CLEAN_COMMAS, @",", NPPRegExFlagGDMI);
	
	NSArray *components = [address componentsSeparatedByString:@","];
	NSString *part = nil;
	NSString *text = nil;
	NSUInteger i = 0;
	NSUInteger count = [components count];
	
	// Street.
	if (count > i && (override || _line1.length == 0))
	{
		part = [components objectAtIndex:i];
		text = nppRegExReplace(part, kNPPREGEX_CLEAN_STREET, @"", NPPRegExFlagGDMI);
		
		self.line1 = text;
		++i;
	}
	
	// Number.
	if (count > i && (override || _line2.length == 0))
	{
		part = [components objectAtIndex:i];
		text = nppRegExReplace(part, kNPPREGEX_CLEAN_NUMBER, @"$1", NPPRegExFlagGDMI);
		
		self.line2 = text;
		++i;
	}
	
	// Neighborhood.
	if (count > i && (override || _neighborhood.length == 0))
	{
		text = [components objectAtIndex:i];
		self.neighborhood = text;
		++i;
	}
	
	// City.
	if (count > i && (override || _city.length == 0))
	{
		text = [components objectAtIndex:i];
		self.city = text;
		++i;
	}
	//*/
}

- (BOOL) isNearToAddress:(NPPModelAddressVO *)address withRay:(double)meters
{
	return ([_geolocation distanceToGeolocation:address.geolocation] < meters);
}

- (BOOL) hasGeolocation
{
	return _geolocation.latitude != 0.0 && _geolocation.longitude != 0.0;
}

- (double) distanceToAddress:(NPPModelAddressVO *)address
{
	return [_geolocation distanceToGeolocation:address.geolocation];
}

- (NSString *) distanceStringToAddress:(NPPModelAddressVO *)address
{
	return [_geolocation distanceStringToGeolocation:address.geolocation];
}

+ (void) defineShortAddressFormat:(NSString *)format
{
	nppRelease(_defaultShortFormat);
	_defaultShortFormat = (format.length > 0) ? [format copy] : [kNPPAddressShort copy];
}

+ (void) defineFullAddressFormat:(NSString *)format
{
	nppRelease(_defaultFullFormat);
	_defaultFullFormat = (format.length > 0) ? [format copy] : [kNPPAddressFull copy];
}

+ (void) definePoliticalAddressFormat:(NSString *)format
{
	nppRelease(_defaultPoliticalFormat);
	_defaultPoliticalFormat = (format.length > 0) ? [format copy] : [kNPPAddressPolitical copy];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) decodeJSONObject:(id)data
{
	// Avoids invalid data formats.
	if (![self checkCompatibility:&data checkClass:[NSDictionary class]])
	{
		return;
	}
	
	// Example:
	// {postal_code:1234,line1:Boris Street,line2:St Angela,neighborhood:Brooklyn,
	// city:New York,state:New York,country:{...},geolocation:{...}}
	
	self.identifier = [[data objectForKey:@"id"] description];
	self.tag = [[data objectForKey:@"tag"] intValue];
	self.mode = [[data objectForKey:@"mode"] intValue];
	self.date = [data objectForKey:@"date"];
	self.name = [data objectForKey:@"name"];
	self.postalCode = [data objectForKey:@"postal_code"];
	self.line1 = [data objectForKey:@"line1"];
	self.line2 = [data objectForKey:@"line2"];
	self.neighborhood = [data objectForKey:@"neighborhood"];
	self.city = [data objectForKey:@"city"];
	self.state = [data objectForKey:@"state"];
	self.country = [NPPModelCountryVO modelWithJSONObject:[data objectForKey:@"country"]];
	self.geolocation = [NPPModelGeolocationVO modelWithJSONObject:[data objectForKey:@"geolocation"]];
}

- (id) encodeJSONObject
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObjectSafely:[NSNumber numberWithInt:_tag] forKey:@"tag"];
	[dict setObjectSafely:[NSNumber numberWithInt:_mode] forKey:@"mode"];
	[dict setObjectSafely:_date forKey:@"date"];
	[dict setObjectSafely:_identifier forKey:@"id"];
	[dict setObjectSafely:_name forKey:@"name"];
	[dict setObjectSafely:_postalCode forKey:@"postal_code"];
	[dict setObjectSafely:_line1 forKey:@"line1"];
	[dict setObjectSafely:_line2 forKey:@"line2"];
	[dict setObjectSafely:_neighborhood forKey:@"neighborhood"];
	[dict setObjectSafely:_city forKey:@"city"];
	[dict setObjectSafely:_state forKey:@"state"];
	[dict setObjectSafely:_country forKey:@"country"];
	[dict setObjectSafely:_geolocation forKey:@"geolocation"];
	
	return dict;
}

- (BOOL) isEqual:(id)object
{
	BOOL result = NO;
	
	// Use class directly instead of "self", because it compare subclasses as well.
	if ([object isKindOfClass:[NPPModelAddressVO class]])
	{
		result = [_geolocation isEqual:[object geolocation]];
		
		if (!result)
		{
			NSString *name = [object name];
			NSString *line1 = [object line1];
			NSString *line2 = [object line2];
			NSString *sub = [object neighborhood];
			NSString *city = [object city];
			BOOL hasName = ((_name == nil && name == nil) || [_name isEqualToString:name]);
			BOOL hasLine1 = ((_line1 == nil && line1 == nil) || [_line1 isEqualToString:line1]);
			BOOL hasLine2 = ((_line2 == nil && line2 == nil) || [_line2 isEqualToString:line2]);
			BOOL hasSub = ((_neighborhood == nil && sub == nil) || [_neighborhood isEqualToString:sub]);
			BOOL hasCity = ((_city == nil && city == nil) || [_city isEqualToString:city]);
			
			result = (hasName && hasLine1 && hasLine2 && hasSub && hasCity);
		}
	}
	
	return result;
}

- (void) dealloc
{
	nppRelease(_date);
	nppRelease(_identifier);
	nppRelease(_name);
	nppRelease(_postalCode);
	nppRelease(_line1);
	nppRelease(_line2);
	nppRelease(_neighborhood);
	nppRelease(_city);
	nppRelease(_state);
	nppRelease(_country);
	nppRelease(_geolocation);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (void) initialize
{
	[self defineShortAddressFormat:nil];
	[self defineFullAddressFormat:nil];
	[self definePoliticalAddressFormat:nil];
}

@end
