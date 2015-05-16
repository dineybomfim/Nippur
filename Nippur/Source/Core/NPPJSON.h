/*
 *	NPPJSON.h
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

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPLogger.h"

@protocol NPPJSONSource <NSObject>

@required

/*!
 *					Returns the JSON data for this object. The data must be one of the basic Obj-C objects:
 *					NSString, NSNumber, NSArray or NSDictionary.
 *
 *	@result			One of the Obj-C basic objects representing the data of this model.
 */
- (id) dataForJSON;

@end

/*!
 *					This JSON class is capable of encode and decode JSON format strings and data objects.
 *					
 *					It can deal with any kind of object that implements the #NPPJSONSource# protocol.
 */
@interface NPPJSON : NSObject

/*!
 *					Decodes a string with JSON format, returning a native objects.
 *
 *	@param			string
 *					A string with JSON format.
 *
 *	@result			One of the Obj-C basic objects representing the data. Can be NSArray or NSDictionary.
 */
+ (id) objectWithString:(NSString *)string;

/*!
 *					Encodes a native object (NSArray or NSDictionary), returning a string with JSON format.
 *
 *	@param			object
 *					A native object to encode into JSON format. Can be NSArray or NSDictionary.
 *
 *	@result			A string encoded in JSON format.
 */
+ (NSString *) stringWithObject:(id)object;

/*!
 *					Decodes a data with JSON format using UTF-8, returning a native objects.
 *
 *	@param			string
 *					A string with JSON format.
 *
 *	@result			One of the Obj-C basic objects representing the data. Can be NSArray or NSDictionary.
 */
+ (id) objectWithData:(NSData *)data;

/*!
 *					Encodes a native object (NSArray or NSDictionary), returning a data with JSON format
 *					using UTF-8.
 *
 *	@param			object
 *					A native object to encode into JSON format. Can be NSArray or NSDictionary.
 *
 *	@result			A data encoded in JSON format with UTF-8.
 */
+ (NSData *) dataWithObject:(id)object;

/*!
 *					This method defines if the JSON will be generated considering the null values
 *					or not. When defining this method to YES, it means the JSON will completely ignore
 *					keys containing empty, blank and null values.
 *
 *	@param			isSkipping
 *					A BOOL indicating if the next JSONs will skip the empty, blank and null values.
 */
+ (void) defineSkipInvalidParameters:(BOOL)isSkipping;

@end