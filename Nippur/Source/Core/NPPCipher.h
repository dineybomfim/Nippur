/*
 *	NPPCipher.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 1/26/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPString+NSString.h"

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

@end

@interface NSData(NPPCipherData)

- (NSData *) encodeBase16;
- (NSData *) decodeBase16;
- (NSData *) encodeBase32;
- (NSData *) decodeBase32;
- (NSData *) encodeBase64;
- (NSData *) decodeBase64;
- (NSData *) encodeBase64WebSafe;
- (NSData *) decodeBase64WebSafe;

- (NSData *) encodeHMACSHA1:(NSData *)secret;

//- (NSData *) gzippedDataWithCompressionLevel:(float)level;
//- (NSData *) gzippedData;
//- (NSData *) gunzippedData;

@end