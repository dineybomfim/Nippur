/*
 *	NPPCipher.h
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

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPPluginString.h"

/*!
 *					This category provides a set of cipher and encriptions to a basic string object.
 */
@interface NSString(NPPCipherString)

// Reversible ciphers.
- (NSString *) encodeHTMLURL;
- (NSString *) decodeHTMLURL;
- (NSString *) encodeHTMLFull;
- (NSString *) decodeHTMLFull;
- (NSString *) encodeBase16;
- (NSString *) decodeBase16;
- (NSString *) encodeBase32;
- (NSString *) decodeBase32;
- (NSString *) encodeBase64;
- (NSString *) decodeBase64;
- (NSString *) encodeBase64WebSafe;
- (NSString *) decodeBase64WebSafe;
- (NSString *) encodeHexadecimal;
- (NSString *) decodeHexadecimal;
- (NSString *) encodeColumnarTransposition:(NSString *)secret;
- (NSString *) decodeColumnarTransposition:(NSString *)secret;
- (NSString *) encodePolygraphicSubstitution:(NSString *)secret;
- (NSString *) decodePolygraphicSubstitution:(NSString *)secret;
- (NSString *) encodeDoubleColumnar;
- (NSString *) decodeDoubleColumnar;

// Unreversible ciphers.
- (NSString *) encodeMD5;

// HTTP encodings
+ (NSString *) stringWithHTTPParams:(NSDictionary *)params;
- (NSDictionary *) httpParams;

@end

/*!
 *					This category provides a set of cipher and encriptions to a basic data object.
 */
@interface NSData(NPPCipherData)

// Reversible ciphers.
- (NSData *) encodeBase16;
- (NSData *) decodeBase16;
- (NSData *) encodeBase32;
- (NSData *) decodeBase32;
- (NSData *) encodeBase64;
- (NSData *) decodeBase64;
- (NSData *) encodeBase64WebSafe;
- (NSData *) decodeBase64WebSafe;

// Unreversible ciphers.
- (NSData *) encodeHMACSHA1:(NSData *)secret;

// HTTP encodings.
+ (NSData *) dataWithHTTPParams:(NSDictionary *)params;
- (NSDictionary *) httpParams;

//- (NSData *) gzippedDataWithCompressionLevel:(float)level;
//- (NSData *) gzippedData;
//- (NSData *) gunzippedData;

@end