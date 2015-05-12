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
 *					for any operation between any numeric data type and is comparisons are extended to
 *					any other class that can respondes to a call "doubleValue".
 *
 *					The greatest advantage is that its value can be changed at any time without
 *					creating new instances. This is helpful when working with retained instances, like
 *					the objects inside a NSArray, NSDictionary or any other Obj-C collection.
 *
 *					The NPPNumber assumes a "working data type" based on the last interaction with it,
 *					for example, if you manipulate it using "int" it will assumes the int as the working
 *					data type. Some time after this, you make a new interaction with the same NPPNumber
 *					instance, but at this time using a float data type, from now on the NPPNumber
 *					assumes the working data type is a float. Regardless the data type, you can always
 *					exchange values between any numeric data type.
 */
/*
@interface NPPNumber : NSObject
{
@private
	char					_format;
	double					_value;
}

@property (nonatomic) char charValue;
@property (nonatomic) unsigned char unsignedCharValue;
@property (nonatomic) short shortValue;
@property (nonatomic) unsigned short unsignedShortValue;
@property (nonatomic) int intValue;
@property (nonatomic) unsigned int unsignedIntValue;
@property (nonatomic) long longValue;
@property (nonatomic) unsigned long unsignedLongValue;
@property (nonatomic) long long longLongValue;
@property (nonatomic) unsigned long long unsignedLongLongValue;
@property (nonatomic) float floatValue;
@property (nonatomic) double doubleValue;
@property (nonatomic) BOOL boolValue;
@property (nonatomic) NSInteger integerValue;
@property (nonatomic) NSUInteger unsignedIntegerValue;

- (void *) pointerValue;

- (NSString *) stringValue;

- (NSComparisonResult) compare:(id)otherNumber;

- (BOOL) isEqualToNumber:(id)number;

- (NSString *) descriptionWithLocale:(id)locale;

@end

@interface NPPNumber(NPPNumberCreation)

- (id) initWithChar:(char)value;
- (id) initWithUnsignedChar:(unsigned char)value;
- (id) initWithShort:(short)value;
- (id) initWithUnsignedShort:(unsigned short)value;
- (id) initWithInt:(int)value;
- (id) initWithUnsignedInt:(unsigned int)value;
- (id) initWithLong:(long)value;
- (id) initWithUnsignedLong:(unsigned long)value;
- (id) initWithLongLong:(long long)value;
- (id) initWithUnsignedLongLong:(unsigned long long)value;
- (id) initWithFloat:(float)value;
- (id) initWithDouble:(double)value;
- (id) initWithBool:(BOOL)value;
- (id) initWithInteger:(NSInteger)value;
- (id) initWithUnsignedInteger:(NSUInteger)value;

+ (id) numberWithChar:(char)value;
+ (id) numberWithUnsignedChar:(unsigned char)value;
+ (id) numberWithShort:(short)value;
+ (id) numberWithUnsignedShort:(unsigned short)value;
+ (id) numberWithInt:(int)value;
+ (id) numberWithUnsignedInt:(unsigned int)value;
+ (id) numberWithLong:(long)value;
+ (id) numberWithUnsignedLong:(unsigned long)value;
+ (id) numberWithLongLong:(long long)value;
+ (id) numberWithUnsignedLongLong:(unsigned long long)value;
+ (id) numberWithFloat:(float)value;
+ (id) numberWithDouble:(double)value;
+ (id) numberWithBool:(BOOL)value;
+ (id) numberWithInteger:(NSInteger)value;
+ (id) numberWithUnsignedInteger:(NSUInteger)value;

@end
/*/
@interface NPPNumber : NSNumber
{
@private
	char					_format;
	double					_value;
}

- (void) setCharValue:(char)value;
- (void) setUnsignedCharValue:(unsigned char)value;
- (void) setShortValue:(short)value;
- (void) setUnsignedShortValue:(unsigned short)value;
- (void) setIntValue:(int)value;
- (void) setUnsignedIntValue:(unsigned int)value;
- (void) setLongValue:(long)value;
- (void) setUnsignedLongValue:(unsigned long)value;
- (void) setLongLongValue:(long long)value;
- (void) setUnsignedLongLongValue:(unsigned long long)value;
- (void) setFloatValue:(float)value;
- (void) setDoubleValue:(double)value;
- (void) setBoolValue:(BOOL)value;
- (void) setIntegerValue:(NSInteger)value;
- (void) setUnsignedIntegerValue:(NSUInteger)value;

@end
//*/