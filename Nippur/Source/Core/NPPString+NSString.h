/*
 *	NPPString+NSString.h
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