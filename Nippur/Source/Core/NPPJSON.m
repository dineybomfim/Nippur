/*
 *	NPPJSON.m
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

#import "NPPJSON.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define nppSkipWhite(c) while (isspace(*c)) c++
#define nppSkipDigit(c) while (isdigit(*c)) c++

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

// The ASCII 32 control characters + 2 (\", \\)
static char ctrl[0x22];

static NSMutableCharacterSet *kEscapeChars = nil;

static BOOL _humanReadable = NO;

static BOOL _isSkipping = NO;

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

@interface NPPJSON()
{
@private
	NSUInteger depth, maxDepth;
	const char *c;
}

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPJSON

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		maxDepth = 512;
	}
	
	return self;
}

+ (void) initialize
{
	// The two special characters.
	ctrl[0] = '\"';
	ctrl[1] = '\\';
	
	// The 32 Control Characters. 0 goes at the end for performance reasons.
	for (int i = 1; i < 0x20; i++)
	{
		ctrl[i+1] = i;
	}
	ctrl[0x21] = 0;
	
	// The escape chars for the writer
	if (kEscapeChars == nil)
	{
		kEscapeChars = [[NSMutableCharacterSet alloc] init];
		[kEscapeChars addCharactersInRange:NSMakeRange(0,32)];
		[kEscapeChars addCharactersInString: @"\"\\"];
	}
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (id) fragmentWithString:(id)repr
{
	// Avoids invalid data.
	if (repr == nil)
	{
		return nil;
	}
	
	depth = 0;
	c = [repr UTF8String];
	
	id o = nil;
	if (![self scanValue:&o])
	{
		return nil;
	}
	
	// We found some valid JSON. But did it also contain something else?
	if (![self scanIsAtEnd])
	{
		nppLog(@"Garbage after JSON");
		return nil;
	}
	
	return o;
}

- (BOOL) scanValue:(NSObject **)o
{
	nppSkipWhite(c);
	
	switch (*c++)
	{
		case '{':
			return [self scanRestOfDictionary:(NSMutableDictionary **)o];
			break;
		case '[':
			return [self scanRestOfArray:(NSMutableArray **)o];
			break;
		case '"':
			return [self scanRestOfString:(NSMutableString **)o];
			break;
		case 'f':
			return [self scanRestOfFalse:(NSNumber **)o];
			break;
		case 't':
			return [self scanRestOfTrue:(NSNumber **)o];
			break;
		case 'n':
			return [self scanRestOfNull:(NSNull **)o];
			break;
		case '-':
		case '0'...'9':
			c--; // cannot verify number correctly without the first character
			return [self scanNumber:(NSNumber **)o];
			break;
		default:
			break;
	}
	
	nppLog(@"Unrecognised leading character");
	return NO;
}

- (BOOL) scanRestOfTrue:(NSNumber **)o
{
	if (!strncmp(c, "rue", 3)) {
		c += 3;
		*o = [NSNumber numberWithBool:YES];
		return YES;
	}
	
	nppLog(@"Expected 'true'");
	return NO;
}

- (BOOL) scanRestOfFalse:(NSNumber **)o
{
	if (!strncmp(c, "alse", 4))
	{
		c += 4;
		*o = [NSNumber numberWithBool:NO];
		return YES;
	}
	
	nppLog(@"Expected 'false'");
	return NO;
}

- (BOOL) scanRestOfNull:(NSNull **)o
{
	if (!strncmp(c, "ull", 3)) {
		c += 3;
		if (!_isSkipping)
		{
			*o = [NSNull null];
		}
		return YES;
	}
	
	nppLog(@"Expected 'null'");
	return NO;
}

- (BOOL) scanRestOfArray:(NSMutableArray **)o
{
	if (maxDepth && ++depth > maxDepth)
	{
		nppLog(@"Nested too deep");
		return NO;
	}
	
	*o = [NSMutableArray arrayWithCapacity:8];
	
	for (; *c ;)
	{
		id v = nil;
		
		nppSkipWhite(c);
		if (*c == ']' && c++)
		{
			depth--;
			if (_isSkipping && [*o count] == 0)
			{
				*o = nil;
			}
			return YES;
		}
		
		if (![self scanValue:&v])
		{
			nppLog(@"Expected value while parsing array");
			return NO;
		}
		
		if (v != nil)
		{
			[*o addObject:v];
		}
		
		nppSkipWhite(c);
		if (*c == ',' && c++)
		{
			nppSkipWhite(c);
			if (*c == ']')
			{
				nppLog(@"Trailing comma disallowed in array");
				return NO;
			}
		}
	}
	
	nppLog(@"End of input while parsing array");
	return NO;
}

- (BOOL) scanRestOfDictionary:(NSMutableDictionary **)o
{
	if (maxDepth && ++depth > maxDepth)
	{
		nppLog(@"Nested too deep");
		return NO;
	}
	
	*o = [NSMutableDictionary dictionaryWithCapacity:7];
	
	for (; *c ;)
	{
		id k = nil;
		id v = nil;
		
		nppSkipWhite(c);
		if (*c == '}' && c++)
		{
			depth--;
			if (_isSkipping && [*o count] == 0)
			{
				*o = nil;
			}
			return YES;
		}
		
		if (!(*c == '\"' && c++ && [self scanRestOfString:&k]))
		{
			nppLog(@"Object key string expected");
			return NO;
		}
		
		nppSkipWhite(c);
		if (*c != ':')
		{
			nppLog(@"Expected ':' separating key and value");
			return NO;
		}
		
		c++;
		if (![self scanValue:&v])
		{
			nppLog(@"Object value expected for key: %@", k);
			return NO;
		}
		
		if (v != nil)
		{
			[*o setObject:v forKey:k];
		}
		
		nppSkipWhite(c);
		if (*c == ',' && c++)
		{
			nppSkipWhite(c);
			if (*c == '}')
			{
				nppLog(@"Trailing comma disallowed in object");
				return NO;
			}
		}
	}
	
	nppLog(@"End of input while parsing object");
	return NO;
}

- (BOOL) scanRestOfString:(NSMutableString **)o
{
	*o = [NSMutableString stringWithCapacity:16];
	do
	{
		// First see if there's a portion we can grab in one go.
		// Doing this caused a massive speedup on the long string.
		size_t len = strcspn(c, ctrl);
		if (len)
		{
			// check for
			id t = [[NSString alloc] initWithBytesNoCopy:(char*)c
												  length:len
												encoding:NSUTF8StringEncoding
											freeWhenDone:NO];
			if (t)
			{
				[*o appendString:t];
				nppRelease(t);
				c += len;
			}
		}
		
		if (*c == '"')
		{
			c++;
			if (_isSkipping && [*o length] == 0)
			{
				*o = nil;
			}
			return YES;
			
		}
		else if (*c == '\\')
		{
			unichar uc = *++c;
			switch (uc) {
				case '\\':
				case '/':
				case '"':
					break;
					
				case 'b':   uc = '\b';  break;
				case 'n':   uc = '\n';  break;
				case 'r':   uc = '\r';  break;
				case 't':   uc = '\t';  break;
				case 'f':   uc = '\f';  break;
					
				case 'u':
					c++;
					if (![self scanUnicodeChar:&uc])
					{
						nppLog(@"Broken unicode character");
						return NO;
					}
					c--; // hack.
					break;
				default:
					nppLog(@"Illegal escape sequence '0x%x'", uc);
					return NO;
					break;
			}
			CFStringAppendCharacters((NPP_ARC_BRIDGE CFMutableStringRef)*o, &uc, 1);
			c++;
		}
		else if (*c < 0x20)
		{
			nppLog(@"Unescaped control character '0x%x'", *c);
			return NO;
		}
		else
		{
			nppLog(@"should not be able to get here");
		}
	} while (*c);
	
	nppLog(@"Unexpected EOF while parsing string");
	return NO;
}

- (BOOL) scanUnicodeChar:(unichar *)x
{
	unichar hi = 0x0, lo = 0x0;
	
	if (![self scanHexQuad:&hi])
	{
		nppLog(@"Missing hex quad");
		return NO;
	}
	
	if (hi >= 0xd800)
	{	 // high surrogate char?
		if (hi < 0xdc00)
		{  // yes - expect a low char
			
			if (!(*c == '\\' && ++c && *c == 'u' && ++c && [self scanHexQuad:&lo]))
			{
				nppLog(@"Missing low character in surrogate pair");
				return NO;
			}
			
			if (lo < 0xdc00 || lo >= 0xdfff)
			{
				nppLog(@"Invalid low surrogate char");
				return NO;
			}
			
			hi = (hi - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000;
			
		}
		else if (hi < 0xe000)
		{
			nppLog(@"Invalid high character in surrogate pair");
			return NO;
		}
	}
	
	*x = hi;
	
	return YES;
}

- (BOOL) scanHexQuad:(unichar *)x
{
	*x = 0;
	for (int i = 0; i < 4; i++)
	{
		unichar uc = *c;
		c++;
		int d = (uc >= '0' && uc <= '9')
		? uc - '0' : (uc >= 'a' && uc <= 'f')
		? (uc - 'a' + 10) : (uc >= 'A' && uc <= 'F')
		? (uc - 'A' + 10) : -1;
		if (d == -1)
		{
			nppLog(@"Missing hex digit in quad");
			return NO;
		}
		*x *= 16;
		*x += d;
	}
	return YES;
}

- (BOOL) scanNumber:(NSNumber **)o
{
	const char *ns = c;
	
	// The logic to test for validity of the number formatting is relicensed
	// from JSON::XS with permission from its author Marc Lehmann.
	// (Available at the CPAN: http://search.cpan.org/dist/JSON-XS/ .)
	
	if ('-' == *c)
		c++;
	
	if ('0' == *c && c++)
	{
		if (isdigit(*c))
		{
			nppLog(@"Leading 0 disallowed in number");
			return NO;
		}
		
	} else if (!isdigit(*c) && c != ns)
	{
		nppLog(@"No digits after initial minus");
		return NO;
		
	} else {
		nppSkipDigit(c);
	}
	
	// Fractional part
	if ('.' == *c && c++)
	{
		if (!isdigit(*c))
		{
			nppLog(@"No digits after decimal point");
			return NO;
		}
		nppSkipDigit(c);
	}
	
	// Exponential part
	if ('e' == *c || 'E' == *c)
	{
		c++;
		if ('-' == *c || '+' == *c)
		{
			c++;
		}
		
		if (!isdigit(*c))
		{
			nppLog(@"No digits after exponent");
			return NO;
		}
		nppSkipDigit(c);
	}
	
	id str = [[NSString alloc] initWithBytesNoCopy:(char*)ns
											length:c - ns
										  encoding:NSUTF8StringEncoding
									  freeWhenDone:NO];
	
	BOOL toReturn;
	if (str && (*o = [NSDecimalNumber decimalNumberWithString:str]))
	{
		toReturn = YES;
	}
	else
	{
		toReturn = NO;
		nppLog(@"Failed creating decimal instance");
	}
	
	nppRelease(str);
	
	return toReturn;
}

- (BOOL) scanIsAtEnd
{
	nppSkipWhite(c);
	return !*c;
}























- (NSString *) stringWithFragment:(id)value
{
	depth = 0;
	NSMutableString *json = [NSMutableString stringWithCapacity:128];
	
	if ([self appendValue:value into:json])
	{
		return json;
	}
	
	return nil;
}

- (NSString *) indent
{
	NSString *ident = @"\n";
	return [ident stringByPaddingToLength:((2 * depth) + 1) withString:@" " startingAtIndex:0];
}

- (BOOL) appendValue:(id)fragment into:(NSMutableString*)json
{
	BOOL keep = YES;
	
	if ([fragment isKindOfClass:[NSDictionary class]])
	{
		keep = [self appendDictionary:fragment into:json];
	}
	else if ([fragment isKindOfClass:[NSArray class]])
	{
		keep = [self appendArray:fragment into:json];
	}
	else if ([fragment isKindOfClass:[NSString class]])
	{
		keep = [self appendString:fragment into:json];
	}
	else if ([fragment isKindOfClass:[NSNumber class]])
	{
		if ('c' == *[fragment objCType])
		{
			[json appendString:[fragment boolValue] ? @"true" : @"false"];
		}
		else
		{
			[json appendString:[fragment stringValue]];
		}
	}
	else if ([fragment respondsToSelector:@selector(dataForJSON)])
	{
		[self appendValue:[fragment dataForJSON] into:json];
	}
	else if ([fragment isKindOfClass:[NSNull class]])
	{
		[json appendString:@"null"];
	}
	else if ([fragment isKindOfClass:[NSDate class]])
	{
		keep = [self appendString:[fragment description] into:json];
	}
	else
	{
		nppLog(@"JSON serialisation not supported for %@", [fragment class]);
		keep = NO;
	}
	
	return keep;
}

- (BOOL) appendArray:(NSArray*)fragment into:(NSMutableString*)json
{
	if (maxDepth && ++depth > maxDepth)
	{
		nppLog(@"Nested too deep");
		return NO;
	}
	[json appendString:@"["];
	
	BOOL addComma = NO;
	for (id value in fragment)
	{
		if (addComma)
		{
			[json appendString:@","];
		}
		else
		{
			addComma = YES;
		}
		
		if (_humanReadable)
		{
			[json appendString:[self indent]];
		}
		
		if (![self appendValue:value into:json])
		{
			return NO;
		}
	}
	
	depth--;
	if (_humanReadable && [fragment count])
	{
		[json appendString:[self indent]];
	}
	[json appendString:@"]"];
	return YES;
}

- (BOOL) appendDictionary:(NSDictionary *)fragment into:(NSMutableString *)json
{
	if (maxDepth && ++depth > maxDepth)
	{
		nppLog(@"Nested too deep");
		return NO;
	}
	
	[json appendString:@"{"];
	
	NSString *colon = _humanReadable ? @" : " : @":";
	BOOL addComma = NO;
	NSArray *keys = [fragment allKeys];
	
	id object = nil;
	Class classString = [NSString class];
	Class classNull = [NSNull class];
	SEL selCount = @selector(count);
	
	for (id value in keys)
	{
		object = [fragment objectForKey:value];
		
		// Skipping all empty, blank or null values inside the dictionary.
		if (_isSkipping)
		{
			if (([object isKindOfClass:classString] && [object length] == 0) ||
				([object respondsToSelector:selCount] && [object count] == 0) ||
				[object isKindOfClass:classNull])
			{
				continue;
			}
		}
		
		if (addComma)
		{
			[json appendString:@","];
		}
		else
		{
			addComma = YES;
		}
		
		if (_humanReadable)
		{
			[json appendString:[self indent]];
		}
		
		if (![value isKindOfClass:classString])
		{
			nppLog(@"JSON object key must be string");
			return NO;
		}
		
		if (![self appendString:value into:json])
		{
			return NO;
		}
		
		[json appendString:colon];
		if (![self appendValue:object into:json])
		{
			nppLog(@"Unsupported value for key %@ in object", value);
			return NO;
		}
	}
	
	depth--;
	if (_humanReadable && [fragment count])
	{
		[json appendString:[self indent]];
	}
	[json appendString:@"}"];
	return YES;
}

- (BOOL) appendString:(NSString*)fragment into:(NSMutableString*)json
{	
	[json appendString:@"\""];
	
	NSRange esc = [fragment rangeOfCharacterFromSet:kEscapeChars];
	if ( !esc.length )
	{
		// No special chars -- can just add the raw string:
		[json appendString:fragment];
	}
	else
	{
		NSUInteger length = [fragment length];
		for (NSUInteger i = 0; i < length; i++)
		{
			unichar uc = [fragment characterAtIndex:i];
			switch (uc)
			{
				case '"':
					[json appendString:@"\\\""];
					break;
				case '\\':
					[json appendString:@"\\\\"];
					break;
				case '\t':
					[json appendString:@"\\t"];
					break;
				case '\n':
					[json appendString:@"\\n"];
					break;
				case '\r':
					[json appendString:@"\\r"];
					break;
				case '\b':
					[json appendString:@"\\b"];
					break;
				case '\f':
					[json appendString:@"\\f"];
					break;
				default:
					if (uc < 0x20)
					{
						[json appendFormat:@"\\u%04x", uc];
					}
					else
					{
						CFStringAppendCharacters((NPP_ARC_BRIDGE CFMutableStringRef)json, &uc, 1);
					}
					break;
					
			}
		}
	}
	
	[json appendString:@"\""];
	return YES;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (id) objectWithString:(NSString *)string
{
	NPPJSON *parser = [[self alloc] init];
	id o = [parser fragmentWithString:string];
	nppRelease(parser);
	
	// Check that the object we've found is a valid JSON container.
	if (![o isKindOfClass:[NSDictionary class]] && ![o isKindOfClass:[NSArray class]])
	{
		nppLog(@"No valid type for JSON");
		return nil;
	}
	
	return o;
}

+ (NSString *) stringWithObject:(id)value
{
	NPPJSON *parser = [[self alloc] init];
	NSString *json = nil;
	
	if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
	{
		json = [parser stringWithFragment:value];
	}
	else if ([value respondsToSelector:@selector(dataForJSON)])
	{
		json = [parser stringWithFragment:[value dataForJSON]];
	}
	else
	{
		nppLog(@"This is not valid type for JSON: %@ - %@", NSStringFromClass([value class]), value);
	}
	
	nppRelease(parser);
	
	return json;
}

+ (id) objectWithData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	id object = [self objectWithString:string];
	
	nppRelease(string);
	
	return object;
}

+ (NSData *) dataWithObject:(id)value
{
	NSData *data = [[self stringWithObject:value] dataUsingEncoding:NSUTF8StringEncoding];
	
	return data;
}

+ (void) defineSkipInvalidParameters:(BOOL)isSkipping
{
	_isSkipping = isSkipping;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end
