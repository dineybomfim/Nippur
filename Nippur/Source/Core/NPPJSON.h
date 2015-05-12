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

@interface NPPJSON : NSObject

// JSON strings.
+ (id) objectWithString:(NSString *)string;
+ (NSString *) stringWithObject:(id)value;

// NSData with UTF-8 encode.
+ (id) objectWithData:(NSData *)data;
+ (NSData *) dataWithObject:(id)value;

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