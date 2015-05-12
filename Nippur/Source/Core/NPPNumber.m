/*
 *	NPPNumber.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 11/24/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPNumber.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_NUMBER_CAST			double

//static NSString *const kNPPChar = @"%i";
//static NSString *const kNPPUChar = @"%u";
//static NSString *const kNPPShort = @"%hi";
//static NSString *const kNPPUShort = @"%hu";
//static NSString *const kNPPInt = @"%i";
//static NSString *const kNPPUInt = @"%u";
//static NSString *const kNPPLong = @"%li";
//static NSString *const kNPPULong = @"%lu";
//static NSString *const kNPPLongLong = @"%lli";
//static NSString *const kNPPULongLong = @"%llu";
//static NSString *const kNPPFloat = @"%.7g";
//static NSString *const kNPPDouble = @"%.16g";
//*
#define kNPPChar				'c'
#define kNPPUChar				'C'
#define kNPPShort				's'
#define kNPPUShort				'S'
#define kNPPInt					'i'
#define kNPPUInt				'I'
#define kNPPLong				'l'
#define kNPPULong				'L'
#define kNPPLongLong			'q'
#define kNPPULongLong			'Q'
#define kNPPFloat				'f'
#define kNPPDouble				'd'
//*/



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

@implementation NPPNumber

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************
/*
@dynamic charValue, unsignedCharValue, shortValue, unsignedShortValue, intValue, unsignedIntValue,
		 longValue, unsignedLongValue, longLongValue, unsignedLongLongValue, floatValue, doubleValue,
		 boolValue, integerValue, unsignedIntegerValue;
//*/
- (char) charValue { return (char)_value; }
- (void) setCharValue:(char)value
{
	_format = kNPPChar;
	_value = (NPP_NUMBER_CAST)value;
}

- (unsigned char) unsignedCharValue { return (unsigned char)_value; }
- (void) setUnsignedCharValue:(unsigned char)value
{
	_format = kNPPUChar;
	_value = (NPP_NUMBER_CAST)value;
}

- (short) shortValue { return (short)_value; }
- (void) setShortValue:(short)value
{
	_format = kNPPShort;
	_value = (NPP_NUMBER_CAST)value;
}

- (unsigned short) unsignedShortValue { return (unsigned short)_value; }
- (void) setUnsignedShortValue:(unsigned short)value
{
	_format = kNPPUShort;
	_value = (NPP_NUMBER_CAST)value;
}

- (int) intValue { return (int)_value; }
- (void) setIntValue:(int)value
{
	_format = kNPPInt;
	_value = (NPP_NUMBER_CAST)value;
}

- (unsigned int) unsignedIntValue { return (unsigned int)_value; }
- (void) setUnsignedIntValue:(unsigned int)value
{
	_format = kNPPUInt;
	_value = (NPP_NUMBER_CAST)value;
}

- (long) longValue { return (long)_value; }
- (void) setLongValue:(long)value
{
	_format = kNPPLong;
	_value = (NPP_NUMBER_CAST)value;
}

- (unsigned long) unsignedLongValue { return (unsigned long)_value; }
- (void) setUnsignedLongValue:(unsigned long)value
{
	_format = kNPPULong;
	_value = (NPP_NUMBER_CAST)value;
}

- (long long) longLongValue { return (long long)_value; }
- (void) setLongLongValue:(long long)value
{
	_format = kNPPLongLong;
	_value = (NPP_NUMBER_CAST)value;
}

- (unsigned long long) unsignedLongLongValue { return (unsigned long long)_value; }
- (void) setUnsignedLongLongValue:(unsigned long long)value
{
	_format = kNPPULongLong;
	_value = (NPP_NUMBER_CAST)value;
}

- (float) floatValue { return (float)_value; }
- (void) setFloatValue:(float)value
{
	_format = kNPPFloat;
	_value = (NPP_NUMBER_CAST)value;
}

- (double) doubleValue { return (double)_value; }
- (void) setDoubleValue:(double)value
{
	_format = kNPPDouble;
	_value = (NPP_NUMBER_CAST)value;
}

- (BOOL) boolValue { return (BOOL)_value; }
- (void) setBoolValue:(BOOL)value
{
	_format = kNPPChar;
	_value = (NPP_NUMBER_CAST)value;
}

- (NSInteger) integerValue { return (NSInteger)_value; }
- (void) setIntegerValue:(NSInteger)value
{
#if NPP_64BITS
	_format = kNPPLong;
#else
	_format = kNPPInt;
#endif
	_value = (NPP_NUMBER_CAST)value;
}

- (NSUInteger) unsignedIntegerValue { return (NSUInteger)_value; }
- (void) setUnsignedIntegerValue:(NSUInteger)value
{
#if NPP_64BITS
	_format = kNPPULong;
#else
	_format = kNPPUInt;
#endif
	_value = (NPP_NUMBER_CAST)value;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

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

- (void *) pointerValue
{
	return &_value;
}

- (NSString *) stringValue
{
	return [self description];
}

- (NSComparisonResult) compare:(id)otherNumber
{
	NSComparisonResult result;
	NPP_NUMBER_CAST value = [otherNumber doubleValue];
	
	if (_value > value)
	{
		result = NSOrderedAscending;
	}
	else if (_value < value)
	{
		result = NSOrderedDescending;
	}
	else
	{
		result = NSOrderedSame;
	}
	
	return result;
}

- (BOOL) isEqualToNumber:(id)number
{
	NPP_NUMBER_CAST value = [number doubleValue];
	return (_value == value);
}

- (NSString *) descriptionWithLocale:(id)aLocale
{
	return [self description];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (BOOL) isEqual:(id)object
{
	BOOL result = NO;
	
	if ([object respondsToSelector:@selector(doubleValue)])
	{
		result = [self isEqualToNumber:object];
	}
	
	return result;
}

- (NSString *) description
{
	//*
	return [NSString stringWithFormat:@"%.7g", _value];
	/*/
	NSString *encode = @"%";
	encode = [encode stringByAppendingString:[NSString stringWithCharacters:&_format length:1]];
	return [NSString stringWithFormat:encode,(typeof(_format))_value];
	//*/
}

- (const char *) objCType
{
	return &_format;
}

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end


#pragma mark -
#pragma mark Public Categories
#pragma mark -
//**********************************************************************************************************
//
//	Public Categories
//
//**********************************************************************************************************

@implementation NPPNumber (NPPNumberCreation)

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************
/*
- (id) initWithChar:(char)value
{
	if ((self = [super init]))
	{
		self.charValue = value;
	}
	
	return self;
}

- (id) initWithUnsignedChar:(unsigned char)value
{
	if ((self = [super init]))
	{
		self.unsignedCharValue = value;
	}
	
	return self;
}

- (id) initWithShort:(short)value
{
	if ((self = [super init]))
	{
		self.shortValue = value;
	}
	
	return self;
}

- (id) initWithUnsignedShort:(unsigned short)value
{
	if ((self = [super init]))
	{
		self.unsignedShortValue = value;
	}
	
	return self;
}

- (id) initWithInt:(int)value
{
	if ((self = [super init]))
	{
		self.intValue = value;
	}
	
	return self;
}

- (id) initWithUnsignedInt:(unsigned int)value
{
	if ((self = [super init]))
	{
		self.unsignedIntValue = value;
	}
	
	return self;
}

- (id) initWithLong:(long)value
{
	if ((self = [super init]))
	{
		self.longValue = value;
	}
	
	return self;
}

- (id) initWithUnsignedLong:(unsigned long)value
{
	if ((self = [super init]))
	{
		self.unsignedLongValue = value;
	}
	
	return self;
}

- (id) initWithLongLong:(long long)value
{
	if ((self = [super init]))
	{
		self.longLongValue = value;
	}
	
	return self;
}

- (id) initWithUnsignedLongLong:(unsigned long long)value
{
	if ((self = [super init]))
	{
		self.unsignedLongLongValue = value;
	}
	
	return self;
}

- (id) initWithFloat:(float)value
{
	if ((self = [super init]))
	{
		self.floatValue = value;
	}
	
	return self;
}

- (id) initWithDouble:(double)value
{
	if ((self = [super init]))
	{
		self.doubleValue = value;
	}
	
	return self;
}

- (id) initWithBool:(BOOL)value
{
	if ((self = [super init]))
	{
		self.boolValue = value;
	}
	
	return self;
}

- (id) initWithInteger:(NSInteger)value
{
	if ((self = [super init]))
	{
		self.integerValue = value;
	}
	
	return self;
}

- (id) initWithUnsignedInteger:(NSUInteger)value
{
	if ((self = [super init]))
	{
		self.unsignedIntegerValue = value;
	}
	
	return self;
}
//*/
+ (id) numberWithChar:(char)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.charValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithUnsignedChar:(unsigned char)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.unsignedCharValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithShort:(short)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.shortValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithUnsignedShort:(unsigned short)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.unsignedShortValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithInt:(int)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.intValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithUnsignedInt:(unsigned int)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.unsignedIntValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithLong:(long)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.longValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithUnsignedLong:(unsigned long)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.unsignedLongValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithLongLong:(long long)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.longLongValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithUnsignedLongLong:(unsigned long long)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.unsignedLongLongValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithFloat:(float)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.floatValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithDouble:(double)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.doubleValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithBool:(BOOL)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.boolValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithInteger:(NSInteger)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.integerValue = value;
	return nppAutorelease(number);
}

+ (id) numberWithUnsignedInteger:(NSUInteger)value
{
	NPPNumber *number = [[NPPNumber alloc] init];
	number.unsignedIntegerValue = value;
	return nppAutorelease(number);
}

@end

