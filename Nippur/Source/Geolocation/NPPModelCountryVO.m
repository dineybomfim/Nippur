/*
 *	NPPModelCountryVO.m
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

#import "NPPModelCountryVO.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_COUNTRY_DATA			@"npp_data_countries.json"

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

static NSString *nppCountryGetValue(NSString *countryCode, NSString *key)
{
	id object = nil;
	
	if (countryCode != nil && key != nil)
	{
		//NSDictionary *comp = [NSDictionary dictionaryWithObject:countryCode forKey:NSLocaleCountryCode];
		//NSString *identifier = [NSLocale localeIdentifierFromComponents:comp];
		NSString *identifier = [NSString stringWithFormat:@"_%@", countryCode];
		NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
		object = [local objectForKey:key];
		
		nppRelease(local);
	}
	
	return object;
}

static NSArray *nppCountryGet(NSString *isoCode)
{
	//*************************
	//	Localizing Names
	//*************************
	
	NSData *data = [NSData dataWithContentsOfFile:nppMakePath(NPP_COUNTRY_DATA)];
	NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:nppGetLanguage()];
	NSArray *countriesData = [NPPJSON objectWithData:data];
	NSMutableArray *countries = [NSMutableArray array];
	NSMutableDictionary *country = nil;
	NSString *name = nil;
	NSString *countryCode = nil;
	
	for (country in countriesData)
	{
		countryCode = [country objectForKey:@"code"];
		name = [local displayNameForKey:NSLocaleIdentifier
								  value:[NSString stringWithFormat:@"_%@", countryCode]];
		[country setObject:name forKey:@"name"];
		
		// If it's looking for a specific ISO code, discard all other countries when the one is founds.
		if (isoCode != nil)
		{
			if (nppRegExMatch(countryCode, isoCode, NPPRegExFlagGDMI))
			{
				[countries addObject:country];
				break;
			}
		}
		else
		{
			[countries addObject:country];
		}
	}
	
	nppRelease(local);
	
	//*************************
	//	Sorting Countries
	//*************************
	
	countries = (id)[countries sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
	{
		NSComparisonResult result = NSOrderedSame;
		NSString *name1 = [obj1 objectForKey:@"name"];
		NSString *name2 = [obj2 objectForKey:@"name"];
		result = [name1 localizedCaseInsensitiveCompare:name2];
		
		return result;
	}];
	
	//*************************
	// Removing invalid codes.
	//*************************
	
	Class stringClass = [NSString class];
	NSMutableArray *countriesCheck = [NSMutableArray array];
	
	for (country in countries)
	{
		countryCode = [country objectForKey:@"dial_code"];
		
		// Exclude invalid codes.
		if ([countryCode isKindOfClass:stringClass] && [countryCode length] > 0)
		{
			[countriesCheck addObject:[NPPModelCountryVO modelWithData:country]];
		}
	}
	
	return countriesCheck;
}

static void nppCountryFillCodes(NPPModelCountryVO *countryVO)
{
	NSData *data = [NSData dataWithContentsOfFile:nppMakePath(NPP_COUNTRY_DATA)];
	NSString *isoCode = countryVO.isoCode;
	NSArray *countries = [NPPJSON objectWithData:data];
	NSMutableDictionary *country = nil;
	NSArray *latlng = nil;
	double latitude = 0.0;
	double longitude = 0.0;
	
	for (country in countries)
	{
		if (nppRegExMatch([country objectForKey:@"code"], isoCode, NPPRegExFlagGDMI))
		{
			latlng = [[country objectForKey:@"latlng"] componentsSeparatedByString:@","];
			latitude = [[latlng firstObject] doubleValue];
			longitude = [[latlng objectAtIndex:0] doubleValue];
			countryVO.dialCode = [country objectForKey:@"dial_code"];
			countryVO.languageCode = [country objectForKey:@"lang"];
			countryVO.geolocation = [NPPModelGeolocationVO modelWithLatitude:latitude longitude:longitude];
			break;
		}
	}
}

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

@implementation NPPModelCountryVO

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize name = _name, isoCode = _isoCode, dialCode = _dialCode, languageCode = _languageCode,
			currencyCode = _currencyCode, currencySymbol = _currencySymbol, geolocation = _geolocation,
			groupingSeparator = _groupingSeparator, decimalSeparator = _decimalSeparator,
			decimal = _decimal;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

+ (id) modelWithISOCode:(NSString *)isoCode
{
	NSArray *countriesList = nppCountryGet(isoCode);
	NPPModelCountryVO *countryVO = [countriesList firstObject];
	
	[countryVO makeBasedOnISOCode];
	
	return countryVO;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (NSNumberFormatter *) formatter
{
	if (_isoCode.length == 0)
	{
		return nil;
	}
	
	NSDictionary *components = [NSDictionary dictionaryWithObject:_isoCode forKey:NSLocaleCountryCode];
	NSString *identifier = [NSLocale localeIdentifierFromComponents:components];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	formatter.locale = [NSLocale localeWithLocaleIdentifier:identifier];
	
	if (_currencyCode != nil)
	{
		formatter.currencyCode = _currencyCode;
	}
	
	if (_currencySymbol != nil)
	{
		formatter.currencySymbol = _currencySymbol;
	}
	
	if (_groupingSeparator != nil)
	{
		formatter.currencyGroupingSeparator = _groupingSeparator;
	}
	
	if (_decimalSeparator != nil)
	{
		formatter.currencyDecimalSeparator = _decimalSeparator;
	}
	
	formatter.alwaysShowsDecimalSeparator = _decimal;
	
	return nppAutorelease(formatter);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) makeBasedOnISOCode
{
	NSString *iso = _isoCode;
	NSString *ccode = _currencyCode;
	NSString *csymbol = _currencySymbol;
	
	nppCountryFillCodes(self);
	self.currencyCode = (ccode.length > 0) ? ccode : nppCountryGetValue(iso, NSLocaleCurrencyCode);
	self.currencySymbol = (csymbol.length > 0) ? csymbol : nppCountryGetValue(iso, NSLocaleCurrencySymbol);
}

- (double) valueFromMonetary:(NSString *)monetary
{
	NSNumber *number = nil;
	NSNumberFormatter *formatter = [self formatter];
	
	number = [formatter numberFromString:monetary];
	
	return [number doubleValue];
}

- (NSString *) monetaryFromValue:(double)value useCurrency:(BOOL)currency
{
	NSString *finalString = nil;
	NSNumberFormatter *formatter = [self formatter];
	NSNumber *number = [NSNumber numberWithDouble:value];
	
	if (!currency)
	{
		[formatter setCurrencySymbol:@""];
	}
	
	finalString = [formatter stringFromNumber:number];
	
	return finalString;
}

+ (NSArray *) allLocalizedCountries
{
	return nppCountryGet(nil);
}

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
	// {name:United States,iso_code:US,dial_code:+1,geolocation:{...},c_code:US,c_symbol:$,
	// grouping_separator:",",decimal_separator:".",decimal:true}
	
	self.name = [data objectForKey:@"name"];
	self.isoCode = [data objectForKey:@"code"];
	self.dialCode = [data objectForKey:@"dial_code"];
	self.languageCode = [data objectForKey:@"lang"];
	self.currencyCode = [data objectForKey:@"c_code"];
	self.currencySymbol = [data objectForKey:@"c_symbol"];
	self.geolocation = [NPPModelGeolocationVO modelWithData:[data objectForKey:@"geolocation"]];
	self.groupingSeparator = [data objectForKey:@"thousand_separator"];
	self.decimalSeparator = [data objectForKey:@"decimal_separator"];
	self.decimal = [[data objectForKey:@"decimal"] boolValue];
}

- (id) dataForJSON
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObjectSafely:_name forKey:@"name"];
	[dict setObjectSafely:_isoCode forKey:@"code"];
	[dict setObjectSafely:_dialCode forKey:@"dial_code"];
	[dict setObjectSafely:_languageCode forKey:@"lang"];
	[dict setObjectSafely:_currencyCode forKey:@"c_code"];
	[dict setObjectSafely:_currencySymbol forKey:@"c_symbol"];
	[dict setObjectSafely:_geolocation forKey:@"geolocation"];
	[dict setObjectSafely:_groupingSeparator forKey:@"grouping_separator"];
	[dict setObjectSafely:_decimalSeparator forKey:@"decimal_separator"];
	[dict setObjectSafely:[NSNumber numberWithBool:_decimal] forKey:@"decimal"];
	
	return dict;
}

- (BOOL) isEqual:(id)object
{
	BOOL result = NO;
	
	// Use class directly instead of "self", because it compare subclasses as well.
	if ([object isKindOfClass:[NPPModelCountryVO class]])
	{
		result = _isoCode == [object isoCode] || _dialCode == [object dialCode];
	}
	
	return result;
}

- (void) dealloc
{
	nppRelease(_name);
	nppRelease(_isoCode);
	nppRelease(_dialCode);
	nppRelease(_languageCode);
	nppRelease(_currencyCode);
	nppRelease(_currencySymbol);
	nppRelease(_groupingSeparator);
	nppRelease(_decimalSeparator);
	nppRelease(_geolocation);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
