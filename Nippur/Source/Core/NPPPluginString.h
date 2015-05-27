/*
 *	NPPPluginString.h
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

/*!
 *					This category imbue NSString with a bit more power, converting string content and
 *					providing backward compatibility for deprecated methods.
 */
@interface NSString(NPPString)

/*!
 *					A shortcut to create autoreleased strings. Acts exactly like initWithData:encoding:
 *
 *	@param			data
 *					A NSData object containing the plain text format for a specified encoding.
 *
 *	@param			encoding
 *					The encoding used by data.
 */
+ (NSString *) stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

/*!
 *					Returns a string in camelCaseFormat (first lower case).
 *
 *	@result			An autoreleased string with the format.
 */
- (NSString *) stringCamelCase;

/*!
 *					Returns a string in InverseCamelCaseFormat (first upper case).
 *
 *	@result			An autoreleased string with the format.
 */
- (NSString *) stringInverseCamelCase;

/*!
 *					Returns a string without any accents, that means: àáâã = a, ñ = n, etc.
 *
 *	@result			An autoreleased string with the format.
 */
- (NSString *) stringWithoutAccents;

/*!
 *					Backward compatibility method. Calculates the necessary size to render a string.
 *					Act as the old sizeWithFont:constrainedToSize:lineBreakMode:
 *
 *	@param			font
 *					The font object to be used.
 *
 *	@param			size
 *					The max size of the label to have.
 *
 *	@param			lineBreak
 *					The line break mode.
 *
 *	@result			The size to render this string.
 */
- (CGSize) sizeWithFont:(UIFont *)font
			constrained:(CGSize)size
			  lineBreak:(NSLineBreakMode)lineBreak;

/*!
 *					Backward compatibility method. Calculates the necessary size to render a string.
 *					Act as the old sizeWithFont:fontminFontSize:actualFontSize:forWidth:lineBreakMode:
 *
 *	@param			font
 *					The font object to be used.
 *
 *	@param			size
 *					The size of the font in points.
 *
 *	@param			width
 *					The max width to have.
 *
 *	@param			lineBreak
 *					The line break mode.
 *
 *	@result			The size to render this string.
 */
- (CGSize) sizeWithFont:(UIFont *)font
				minSize:(CGFloat)size
			   forWidth:(CGFloat)width
			  lineBreak:(NSLineBreakMode)lineBreak;

@end