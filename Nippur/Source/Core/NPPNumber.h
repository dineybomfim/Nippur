/*
 *	NPPNumber.h
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

/*!
 *					Defines a new number class. This class is much more flexible and faster. It works
 *					for any operation between any numeric data type and its comparisons are extended to
 *					any other class that responds to #doubleValue# method.
 *
 *					The greatest advantage is that it's mutable, so you can change the value at any time,
 *					easily doing math operations. This is helpful when working with retained instances,
 *					like the objects inside a NSArray, NSDictionary or any other Obj-C collection.
 *
 *					The NPPNumber assumes a "working data type" based on the last interaction with it,
 *					for example, if you manipulate it using "int" it will assume that int is the working
 *					data type. Some time after this, you make a new interaction with the same NPPNumber
 *					instance, but at this time using a float data type, from now on the NPPNumber
 *					assumes the working data type as float. Regardless the data type, you can always
 *					exchange values between any other numeric type.
 */
@interface NPPNumber : NSNumber

/*!
 *					Sets a new value using char data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setCharValue:(char)value;

/*!
 *					Sets a new value using unsigned char data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setUnsignedCharValue:(unsigned char)value;

/*!
 *					Sets a new value using short data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setShortValue:(short)value;

/*!
 *					Sets a new value using unsigned short data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setUnsignedShortValue:(unsigned short)value;

/*!
 *					Sets a new value using int data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setIntValue:(int)value;

/*!
 *					Sets a new value using unsigned int data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setUnsignedIntValue:(unsigned int)value;

/*!
 *					Sets a new value using long data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setLongValue:(long)value;

/*!
 *					Sets a new value using unsigned long data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setUnsignedLongValue:(unsigned long)value;

/*!
 *					Sets a new value using long long data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setLongLongValue:(long long)value;

/*!
 *					Sets a new value using unsigned long long data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setUnsignedLongLongValue:(unsigned long long)value;

/*!
 *					Sets a new value using float data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setFloatValue:(float)value;

/*!
 *					Sets a new value using double data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setDoubleValue:(double)value;

/*!
 *					Sets a new value using BOOL data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setBoolValue:(BOOL)value;

/*!
 *					Sets a new value using NSInteger data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setIntegerValue:(NSInteger)value;

/*!
 *					Sets a new value using NSUInteger data type.
 *
 *	@param			value
 *					The new value.
 */
- (void) setUnsignedIntegerValue:(NSUInteger)value;

@end