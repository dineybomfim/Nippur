/*
 *	NPPString+NSString.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 11/25/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"

@interface NSString(NPPString)

- (NSString *) stringCamelCase;
- (NSString *) stringInverseCamelCase;
- (NSString *) stringWithoutAccents;
- (NSString *) stringWithoutAccentsLower;

- (CGSize) sizeWithFont:(UIFont *)font
			constrained:(CGSize)size
			  lineBreak:(NSLineBreakMode)lineBreak;
- (CGSize) sizeWithFont:(UIFont *)font
				minSize:(CGFloat)size
			   forWidth:(CGFloat)width
			  lineBreak:(NSLineBreakMode)lineBreak;

+ (NSString *) stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

@end