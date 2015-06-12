/*
 *	NPPPluginString.m
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

#import "NPPPluginString.h"

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
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NSString(NPPString)

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

- (NSString *) stringCamelCase
{
	NSString *result = nil;
	NSString *lower = nil;
	
	if (self.length > 0)
	{
		lower = [[self substringToIndex:1] lowercaseString];
		result = [NSString stringWithFormat:@"%@%@", lower, [self substringFromIndex:1]];
	}
	
	return result;
}

- (NSString *) stringInverseCamelCase
{
	NSString *result = nil;
	NSString *upper = nil;
	
	if (self.length > 0)
	{
		upper = [[self substringToIndex:1] uppercaseString];
		result = [NSString stringWithFormat:@"%@%@", upper, [self substringFromIndex:1]];
	}
	
	return result;
}

- (NSString *) stringWithoutAccents
{
	NSLocale *locale = [NSLocale systemLocale];
	return [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
}

+ (NSString *) stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
	NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
	
	return nppAutorelease(string);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end