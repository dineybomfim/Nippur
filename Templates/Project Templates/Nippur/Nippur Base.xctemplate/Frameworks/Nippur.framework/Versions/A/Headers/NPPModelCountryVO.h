/*
 *	NPPModelCountryVO.h
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

#import "NippurCore.h"

#import "NPPModelGeolocationVO.h"

@interface NPPModelCountryVO : NPPModelVO
{
@private
	NSString					*_name;
	NSString					*_isoCode;
	NSString					*_dialCode;
	NSString					*_languageCode;
	NSString					*_currencyCode;
	NSString					*_currencySymbol;
	NSString					*_groupingSeparator;
	NSString					*_decimalSeparator;
	BOOL						_decimal;
	NPPModelGeolocationVO		*_geolocation;
}

@property (nonatomic, NPP_COPY) NSString *name;
@property (nonatomic, NPP_COPY) NSString *isoCode;
@property (nonatomic, NPP_COPY) NSString *dialCode;
@property (nonatomic, NPP_COPY) NSString *languageCode;
@property (nonatomic, NPP_COPY) NSString *currencyCode;
@property (nonatomic, NPP_COPY) NSString *currencySymbol;
@property (nonatomic, NPP_COPY) NSString *groupingSeparator;
@property (nonatomic, NPP_COPY) NSString *decimalSeparator;
@property (nonatomic, getter = hasDecimal) BOOL decimal;
@property (nonatomic, NPP_RETAIN) NPPModelGeolocationVO *geolocation;

+ (id) modelWithISOCode:(NSString *)isoCode;

/*!
 *					Automatically creates dialCode, languageCode and geolocation based on iso country code.
 *					If currencies are not defined yet, also create currency code and currency symbol.
 */
- (void) makeBasedOnISOCode;

/*!
 *					Returns a double value from a monetary string.
 *					A monetary string can be US$ 1,999.00 or just 1,999.00.
 *
 *					If there are currencies defined (currency code, currency symbol, grouping separator and
 *					decimal separator) they will be used, otherwise the system locale will define the
 *					settings based on the iso country code.
 */
- (double) valueFromMonetary:(NSString *)monetary;

/*!
 *					Returns a monetary string from a double value.
 *					A monetary string can be US$ 1,999.00 or just 1,999.00, with or without the currency
 *					option enabled, respectively.
 *
 *					If there are currencies defined (currency code, currency symbol, grouping separator and
 *					decimal separator) they will be used, otherwise the system locale will define the
 *					settings based on the iso country code.
 */
- (NSString *) monetaryFromValue:(double)value useCurrency:(BOOL)currency;

+ (NSArray *) allLocalizedCountries;

@end