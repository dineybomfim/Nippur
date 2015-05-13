/*
 *	NPPCipher.m
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

#import "NPPCipher.h"

//#import <zlib.h>

#import <CommonCrypto/CommonCrypto.h>

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static const char *kNPPBase16 = "0123456789ABCDEF";
static const char *kNPPBase32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
static const char *kNPPBase64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char *kNPPBase64Web = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
NSString *const kNPPCipherKey32	= @"x5Bim1afh40nmnsHer26BnTm37ilOqau";
NSString *const kNPPCipherKey24	= @"ma390bn178NajTN3Maso2JkL";

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

static void nppGetSortedTranspositionKey(unsigned short *secrets, unsigned int length)
{
	int i, j, key;
	unsigned short *sorted = malloc(length * NPP_SIZE_USHORT);
	memcpy(sorted, secrets, length * NPP_SIZE_USHORT);
	
	// Sorting the secrets in ascendent order.
	// Using the Insertion Sort algorithm.
	for (j = 1; j < length; ++j)
	{
		key = sorted[j];
		
		// Starting at the last sorted value in the first array, keep searching in the second array.
		for (i = j - 1; (i >= 0) && (sorted[i] > key); --i)
		{
			sorted[i + 1] = sorted[i];
		}
		
		sorted[i + 1] = key;
	}
	
	// Updating the original secrets with the corresponding sequence indices.
	for (j = 0; j < length; ++j)
	{
		key = sorted[j];
		
		for (i = 0; i < length; ++i)
		{
			if (key == secrets[i])
			{
				// Once the value was found, null it to avoid comparing it again.
				sorted[j] = i;
				secrets[i] = 0;
				break;
			}
		}
	}
	
	// Updating the original array.
	memcpy(secrets, sorted, length * NPP_SIZE_USHORT);
	
	// Frees the memory.
	nppFree(sorted);
}

static NSString *nppTranpositionCipher(NSString *original, NSString *secret, BOOL isEncoding)
{
	// Avoids invalid secrets.
	if (![secret isKindOfClass:[NSString class]] || [secret length] == 0)
	{
		return original;
	}
	
	NSString *result = nil;
	unsigned int current = 0;
	unsigned int i = 0, ic = 0, ir = 0;
	unsigned int selfLength = (unsigned int)[original length];
	unsigned int columnLength = (unsigned int)[secret length];
	unsigned short *secrets = malloc(columnLength * NPP_SIZE_USHORT);
	unsigned short *chars = malloc(selfLength * NPP_SIZE_USHORT);
	unsigned short *transposed = malloc(selfLength * NPP_SIZE_USHORT);
	
	[original getCharacters:chars];
	[secret getCharacters:secrets];
	
	// Getting the sorted sequence from the secret key.
	nppGetSortedTranspositionKey(secrets, columnLength);
	
	for (i = 0; i < selfLength; ++i)
	{
		current = (ir * columnLength) + secrets[ic];
		
		// Transposing char.
		if (current < selfLength)
		{
			// Extremelly clean code, just an if changes from encoding to decoding.
			if (isEncoding)
			{
				transposed[i] = chars[current];
			}
			else
			{
				transposed[current] = chars[i];
			}
			
			++ir;
		}
		// Empty spot, go to the next column.
		else
		{
			ir = 0;
			++ic;
			--i;
		}
	}
	
	result = [NSString stringWithCharacters:transposed length:selfLength];
	
	// Frees the memory.
	nppFree(secrets);
	nppFree(chars);
	nppFree(transposed);
	
	return result;
}

static NSString *nppHexadecimalCipher(NSString *original, BOOL isEncoding)
{
	NSMutableString *result = [[NSMutableString alloc] init];
	unsigned int i = 0;
	unsigned int length = (unsigned int)[original length];
	const char *chars = [original UTF8String];
	unsigned int character = 0;
	
	for (i = 0; i < length; ++i)
	{
		// Extremelly clean code, just an "if" resolves the encoding and the decoding.
		if (isEncoding)
		{
			[result appendFormat:@"%02x", chars[i]];
		}
		else
		{
			sscanf(chars, "%02x", &character);
			[result appendFormat:@"%c", character];
			chars += 2;
			++i;
		}
	}
	
	return nppAutorelease(result);
}

static NSString *nppBaseDataCipher(NSData *theData, const char *table)
{
	NSString *base64 = nil;
	const unsigned char *input = [theData bytes];
	NSInteger length = [theData length];
	
	NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	unsigned char *output = data.mutableBytes;
	
	NSInteger i = 0;
	NSInteger value = 0;
	NSInteger j = 0;
	NSInteger theIndex = 0;
	
	for (i = 0; i < length; i += 3)
	{
		value = 0;
		
		for (j = i; j < (i + 3); j++)
		{
			value <<= 8;
			
			if (j < length)
			{
				value |= (0xFF & input[j]);
			}
		}
		
		theIndex = (i / 3) * 4;
		output[theIndex + 0] = table[(value >> 18) & 0x3F];
		output[theIndex + 1] = table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}
	
	base64 = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
	
	return base64;
}

static NSData *nppBaseDataCipherReverse(NSString *original, const char *table)
{
	//*
	const char *string = [original cStringUsingEncoding:NSUTF8StringEncoding];
	unsigned int inputLength = (unsigned int)strlen(string);
	unsigned int tableLength = (unsigned int)strlen(table);
	unsigned int i = 0;
	
	if (inputLength % 4 != 0)
	{
		return nil;
	}
	
	//*************************
	//	Decoding Table
	//*************************
	
	char decodingTable[128];
	memset(decodingTable, 0, 128);
	
	for (i = 0; i < tableLength; i++)
	{
		decodingTable[table[i]] = i;
	}
	
	//*************************
	//	Decoding
	//*************************
	
	while (inputLength > 0 && string[inputLength - 1] == '=')
	{
		inputLength--;
	}
	
	NSInteger outputLength = (float)inputLength * (3.0f / 4.0f);
	NSMutableData *data = [NSMutableData dataWithLength:outputLength];
	unsigned char *output = data.mutableBytes;
	NSInteger inputPoint = 0;
	NSInteger outputPoint = 0;
	
	while (inputPoint < inputLength)
	{
		char i0 = string[inputPoint++];
		char i1 = string[inputPoint++];
		char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A';
		char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
		
		output[outputPoint++] = (decodingTable[i0] << 2) | (decodingTable[i1] >> 4);
		
		if (outputPoint < outputLength)
		{
			output[outputPoint++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);
		}
		
		if (outputPoint < outputLength)
		{
			output[outputPoint++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];
		}
	}
	/*/
	const char *inBuf = [original cStringUsingEncoding:NSUTF8StringEncoding];
	unsigned int inputLength = strlen(inBuf);
	unsigned int tableLength = strlen(table);
	unsigned int i = 0;
	int shift = 0;
	int decodingTable[128];
	
	if (inputLength % 4 != 0)
	{
		return nil;
	}
	
	//	Decoding Table
	
	memset(decodingTable, -1, 128 * NPP_SIZE_UINT);
	
	for (i = 0; i < tableLength; i++)
	{
		decodingTable[table[i]] = i;
	}
	decodingTable['='] = -2;
	
	for (NSUInteger i = 1; i < tableLength; i <<= 1)
	{
		shift++;
	}
	
	int mask = (1 << shift) - 1;
	
	//	Decoding
	
	NSUInteger outputLength = inputLength * shift / 8;
	NSMutableData *data = [NSMutableData dataWithLength:outputLength];
	unsigned char *output = (unsigned char *)[data mutableBytes];
	NSUInteger outputPoint = 0;
	
	int buffer = 0;
	int bitsLeft = 0;
	BOOL expectPad = NO;
	
	for (NSUInteger i = 0; i < inputLength; i++)
	{
		int val = decodingTable[inBuf[i]];
		
		switch (val)
		{
			case -3:
				break;
			case -2:
				expectPad = YES;
				break;
			case -1:
				return nil;
				break;
			default:
				if (expectPad)
				{
					return nil;
				}
				
				buffer <<= shift;
				buffer |= val & mask;
				bitsLeft += shift;
				
				if (bitsLeft >= 8)
				{
					output[outputPoint++] = buffer >> (bitsLeft - 8);
					bitsLeft -= 8;
				}
				break;
		}
	}
	
	[data setLength:outputPoint];
	//*/
	
	return data;
}

static NSString *nppBaseCipher(NSString *original, const char *table, BOOL isEncoding)
{
	NSData *data = nil;
	NSString *result = nil;
	
	if (isEncoding)
	{
		data = [original dataUsingEncoding:NSUTF8StringEncoding];
		result = nppBaseDataCipher(data, table);
	}
	else
	{
		data = nppBaseDataCipherReverse(original, table);
		result = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return result;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

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

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NSString(NPPCipherString)

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

- (NSString *) encodeHTMLURL
{
	NSString *encoded = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	encoded = [encoded stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	
	return encoded;
}

- (NSString *) decodeHTMLURL
{
	NSString *encoded = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	encoded = [encoded stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
	
	return encoded;
}

- (NSString *) encodeHTMLFull
{
	NSString *encoded = [self encodeHTMLURL];
	encoded = [encoded stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	encoded = [encoded stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
	
	return encoded;
}

- (NSString *) decodeHTMLFull
{
	NSString *encoded = [self decodeHTMLURL];
	encoded = [encoded stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
	encoded = [encoded stringByReplacingOccurrencesOfString:@"%3B" withString:@";"];
	
	return encoded;
}

- (NSString *) encodeBase16
{
	return nppBaseCipher(self, kNPPBase16, YES);
}

- (NSString *) decodeBase16
{
	return nppBaseCipher(self, kNPPBase16, NO);
}

- (NSString *) encodeBase32
{
	return nppBaseCipher(self, kNPPBase32, YES);
}

- (NSString *) decodeBase32
{
	return nppBaseCipher(self, kNPPBase32, NO);
}

- (NSString *) encodeBase64
{
	return nppBaseCipher(self, kNPPBase64, YES);
}

- (NSString *) decodeBase64
{
	return nppBaseCipher(self, kNPPBase64, NO);
}

- (NSString *) encodeBase64WebSafe
{
	return nppBaseCipher(self, kNPPBase64Web, YES);
}

- (NSString *) decodeBase64WebSafe
{
	return nppBaseCipher(self, kNPPBase64Web, NO);
}

- (NSString *) encodeHexadecimal
{
	return nppHexadecimalCipher(self, YES);
}

- (NSString *) decodeHexadecimal
{
	return nppHexadecimalCipher(self, NO);
}

- (NSString *) encodeColumnarTransposition:(NSString *)secret
{
	return nppTranpositionCipher(self, secret, YES);
}

- (NSString *) decodeColumnarTransposition:(NSString *)secret
{
	return nppTranpositionCipher(self, secret, NO);
}

- (NSString *) encodePolygraphicSubstitution:(NSString *)secret
{
	return nil;
}

- (NSString *) decodePolygraphicSubstitution:(NSString *)secret
{
	return nil;
}

- (NSString *) encodeDoubleColumnar
{
	NSString *encoded = self;
	
	encoded = [encoded encodeColumnarTransposition:kNPPCipherKey32];
	encoded = [encoded encodeColumnarTransposition:kNPPCipherKey24];
	
	return encoded;
}

- (NSString *) decodeDoubleColumnar
{
	NSString *decoded = self;
	
	decoded = [decoded decodeColumnarTransposition:kNPPCipherKey24];
	decoded = [decoded decodeColumnarTransposition:kNPPCipherKey32];
	
	return decoded;
}

- (NSString *) encodeMD5
{
	unsigned int i = 0;
	const char *ptr = [self UTF8String];
	unsigned char *md5Buffer = malloc(CC_MD5_DIGEST_LENGTH * NPP_SIZE_CHAR);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	
	// Creates 16 bytes MD5 hash value.
	CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
	
	// Converts MD5 value in the buffer to NSString of hex values.
	for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
	{
		[output appendFormat:@"%02x", md5Buffer[i]];
	}
	
	nppFree(md5Buffer);
	
	return output;
}

// HTTP encodings
+ (NSString *) stringWithHTTPParams:(NSDictionary *)params
{
	NSMutableString *string = [[NSMutableString alloc] init];
	
	// Dictionary params will be converted into string.
	if ([params isKindOfClass:[NSDictionary class]])
	{
		NSString *key = nil;
		NSString *param = nil;
		NSUInteger i = 0;
		NSUInteger count = [params count];
		
		// Constructs the parameters.
		for (key in params)
		{
			// Fully encode the HTML data.
			param = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]];
			[string appendFormat:@"%@%@", [param encodeHTMLFull], (++i < count) ? @"&" : @""];
		}
	}
	
	return nppAutorelease(string);
}

- (NSDictionary *) httpParams
{
	NSString *pattern = @"(#::#)";
	NSString *string = self;
	NSMutableString *raw = nil;
	NSRange range = NPPRangeZero;
	
	// Slicing HTTP domain.
	if ([string hasPrefix:@"http"])
	{
		range = [string rangeOfString:@"?"];
		string = (range.length > 0) ? [string substringFromIndex:range.location + 1] : string;
	}
	
	raw = [NSMutableString stringWithString:string];
	
	// Preparing raw string.
	do
	{
		range = [raw rangeOfString:@"="];
		if (range.length > 0)
		{
			[raw replaceCharactersInRange:range withString:pattern];
		}
		
		range = [raw rangeOfString:@"&"];
		if (range.length > 0)
		{
			[raw replaceCharactersInRange:range withString:pattern];
		}
	}
	while (range.length > 0);
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	NSArray *array = [raw componentsSeparatedByString:pattern];
	NSString *key = nil;
	NSString *value = nil;
	NSUInteger i = 0;
	NSUInteger count = [array count];
	
	for (i = 0; i < count; i += 2)
	{
		if (i + 1 < count)
		{
			key = [[array objectAtIndex:i] decodeHTMLFull];
			value = [[array objectAtIndex:i + 1] decodeHTMLFull];
		}
		else
		{
			key = [NSString stringWithFormat:@"param%i", (int)i];
			value = [[array objectAtIndex:i] decodeHTMLFull];
		}
		
		[params setObject:value forKey:key];
	}
	
	return nppAutorelease(params);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NSData(NPPCipherData)

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

- (NSData *) encodeBase16
{
	NSString *base = nppBaseDataCipher(self, kNPPBase16);
	return [base dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) decodeBase16
{
	NSString *base = [NSString stringWithData:self encoding:NSUTF8StringEncoding];
	return nppBaseDataCipherReverse(base, kNPPBase16);
}

- (NSData *) encodeBase32
{
	NSString *base = nppBaseDataCipher(self, kNPPBase32);
	return [base dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) decodeBase32
{
	NSString *base = [NSString stringWithData:self encoding:NSUTF8StringEncoding];
	return nppBaseDataCipherReverse(base, kNPPBase32);
}

- (NSData *) encodeBase64
{
	NSString *base = nppBaseDataCipher(self, kNPPBase64);
	return [base dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) decodeBase64
{
	NSString *base = [NSString stringWithData:self encoding:NSUTF8StringEncoding];
	return nppBaseDataCipherReverse(base, kNPPBase64);
}

- (NSData *) encodeBase64WebSafe
{
	NSString *base = nppBaseDataCipher(self, kNPPBase64Web);
	return [base dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) decodeBase64WebSafe
{
	NSString *base = [NSString stringWithData:self encoding:NSUTF8StringEncoding];
	return nppBaseDataCipherReverse(base, kNPPBase64Web);
}

- (NSData *) encodeHMACSHA1:(NSData *)secret
{
	NSData *binaryResult = nil;
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, [secret bytes], [secret length], [self bytes], [self length], &result);
	binaryResult = [NSData dataWithBytes:&result length:CC_SHA1_DIGEST_LENGTH];
	
	return binaryResult;
}

// HTTP encodings
+ (NSData *) dataWithHTTPParams:(NSDictionary *)params
{
	NSString *string = [NSString stringWithHTTPParams:params];
	
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *) httpParams
{
	NSString *string = [NSString stringWithData:self encoding:NSUTF8StringEncoding];
	
	return [string httpParams];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end





/*
static const NSUInteger ChunkSize = 16384;

@implementation NSData (GZIP)

- (NSData *)gzippedDataWithCompressionLevel:(float)level
{
	if ([self length])
	{
		z_stream stream;
		stream.zalloc = Z_NULL;
		stream.zfree = Z_NULL;
		stream.opaque = Z_NULL;
		stream.avail_in = (uint)[self length];
		stream.next_in = (Bytef *)[self bytes];
		stream.total_out = 0;
		stream.avail_out = 0;
		
		int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
		if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK)
		{
			NSMutableData *data = [NSMutableData dataWithLength:ChunkSize];
			while (stream.avail_out == 0)
			{
				if (stream.total_out >= [data length])
				{
					data.length += ChunkSize;
				}
				stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
				stream.avail_out = (uInt)([data length] - stream.total_out);
				deflate(&stream, Z_FINISH);
			}
			deflateEnd(&stream);
			data.length = stream.total_out;
			return data;
		}
	}
	return nil;
}

- (NSData *)gzippedData
{
	return [self gzippedDataWithCompressionLevel:-1.0f];
}

- (NSData *)gunzippedData
{
	if ([self length])
	{
		z_stream stream;
		stream.zalloc = Z_NULL;
		stream.zfree = Z_NULL;
		stream.avail_in = (uint)[self length];
		stream.next_in = (Bytef *)[self bytes];
		stream.total_out = 0;
		stream.avail_out = 0;
		
		NSMutableData *data = [NSMutableData dataWithLength:(NSUInteger)([self length] * 1.5)];
		if (inflateInit2(&stream, 47) == Z_OK)
		{
			int status = Z_OK;
			while (status == Z_OK)
			{
				if (stream.total_out >= [data length])
				{
					data.length += [self length] * 0.5;
				}
				stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
				stream.avail_out = (uInt)([data length] - stream.total_out);
				status = inflate (&stream, Z_SYNC_FLUSH);
			}
			if (inflateEnd(&stream) == Z_OK)
			{
				if (status == Z_STREAM_END)
				{
					data.length = stream.total_out;
					return data;
				}
			}
		}
	}
	return nil;
}

@end
//*/