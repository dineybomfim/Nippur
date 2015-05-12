/*
 *	NPPString+NSString.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 11/25/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPString+NSString.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

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
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NSString(NPPString)

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

- (NSString *) stringCamelCase
{
	NSString *result = nil;
	NSString *lower = nil;
	
	if (self.length > 0)
	{
		lower = [[self substringToIndex:1] lowercaseString];
		result = [NSString stringWithFormat:@"%@%@", lower, [self substringFromIndex:1]];
	}
	
	return result;
}

- (NSString *) stringInverseCamelCase
{
	NSString *result = nil;
	NSString *upper = nil;
	
	if (self.length > 0)
	{
		upper = [[self substringToIndex:1] uppercaseString];
		result = [NSString stringWithFormat:@"%@%@", upper, [self substringFromIndex:1]];
	}
	
	return result;
}

- (NSString *) stringWithoutAccents
{
	NSLocale *locale = [NSLocale systemLocale];
	return [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
}

- (NSString *) stringWithoutAccentsLower
{
	return [[self lowercaseString] stringWithoutAccents];
}

- (CGSize) sizeWithFont:(UIFont *)font
			constrained:(CGSize)constrained
			  lineBreak:(NSLineBreakMode)lineBreak
{
	CGSize size = CGSizeZero;
	/*
	size = [self boundingRectWithSize:constrained
							  options:NSStringDrawingUsesLineFragmentOrigin
						   attributes:@{NSFontAttributeName:font}
							  context:nil].size;
	
	size = CGSizeMake(ceilf(size.width), ceilf(size.height));
	/*/
	size = [self sizeWithFont:font constrainedToSize:constrained lineBreakMode:lineBreak];
	//*/
	return size;
}

- (CGSize) sizeWithFont:(UIFont *)font
				minSize:(CGFloat)minSize
			   forWidth:(CGFloat)width
			  lineBreak:(NSLineBreakMode)lineBreak
{
	CGSize size = CGSizeZero;
	/*
	
	/*/
	size = [self sizeWithFont:font
				  minFontSize:minSize
			   actualFontSize:nil
					 forWidth:width
				lineBreakMode:lineBreak];
	//*/
	return size;
}

+ (NSString *) stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
	NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
	
	return nppAutorelease(string);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end