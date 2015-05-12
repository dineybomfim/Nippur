/*
 *	NPPColor+UIColor.m
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

#import "NPPColor+UIColor.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kBY_255				0.00392156862745

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

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

NPPvec4 nppColorMake(float r, float g, float b, float a)
{
	NPPvec4 rgba;
	
	rgba.r = r;
	rgba.g = g;
	rgba.b = b;
	rgba.a = a;
	
	return rgba;
}

NPPvec4 nppColorFromUIColor(UIColor *color)
{
	NPPvec4 rgba = kNPPvec4Zero;
	CGColorRef cgColor = color.CGColor;
	
	size_t numComponents = CGColorGetNumberOfComponents(cgColor);
	const CGFloat *components = CGColorGetComponents(cgColor);
	
	switch (numComponents)
	{
		case 2:
			rgba.r = rgba.g = rgba.b = components[0];
			rgba.a = components[1];
			break;
		case 4:
			rgba.r = components[0];
			rgba.g = components[1];
			rgba.b = components[2];
			rgba.a = components[3];
			break;
		default:
			break;
	}
	
	return rgba;
}

UIColor *nppColorToUIColor(NPPvec4 vec4)
{
	UIColor *color = [UIColor colorWithRed:vec4.r green:vec4.g blue:vec4.b alpha:vec4.a];
	
	return color;
}

NPPRGBA nppRGBAMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
	NPPRGBA rgba;
	
	rgba.r = r;
	rgba.g = g;
	rgba.b = b;
	rgba.a = a;
	
	return rgba;
}

NPPRGBA nppRGBAFromUIColor(UIColor *color)
{
	NPPRGBA rgba = kNPPRGBAZero;
	NPPvec4 vec4 = nppColorFromUIColor(color);
	
	rgba.r = vec4.r * 255;
	rgba.g = vec4.g * 255;
	rgba.b = vec4.b * 255;
	rgba.a = vec4.a * 255;
	
	return rgba;
}

UIColor *nppRGBAToUIColor(NPPRGBA rgba)
{
	NPPvec4 vec4 = kNPPvec4Zero;
	
	vec4.r = rgba.r / 255;
	vec4.g = rgba.g / 255;
	vec4.b = rgba.b / 255;
	vec4.a = rgba.a / 255;
	
	return nppColorToUIColor(vec4);
}

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

// Returns RGBA color format.
static void nppColorHexadecimalFromCGColor(CGColorRef cgColor, unsigned int *rgba)
{
	size_t numComponents = CGColorGetNumberOfComponents(cgColor);
	const CGFloat *components = CGColorGetComponents(cgColor);
	
	switch (numComponents)
	{
		case 2:
			rgba[0] = rgba[1] = rgba[2] = (unsigned int)(components[0] * 255.0f);
			rgba[3] = (unsigned int)components[1] * 255.0f;
			break;
		case 4:
			rgba[0] = (unsigned int)(components[0] * 255.0f);
			rgba[1] = (unsigned int)(components[1] * 255.0f);
			rgba[2] = (unsigned int)(components[2] * 255.0f);
			rgba[3] = (unsigned int)(components[3] * 255.0f);
			break;
		default:
			break;
	}
}

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

@implementation UIColor (NPPColor)

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

- (unsigned int) hexadecimal
{
	unsigned int rgba[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
	nppColorHexadecimalFromCGColor([self CGColor], rgba);
	
	// Outputs ARGB color format.
	return (rgba[3] << 24) + (rgba[0] << 16) + (rgba[1] << 8) + (rgba[2] << 0);
}

- (unsigned int) hexadecimalRGBA
{
	unsigned int rgba[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
	nppColorHexadecimalFromCGColor([self CGColor], rgba);
	
	// Outputs RGBA color format.
	return (rgba[0] << 24) + (rgba[1] << 16) + (rgba[2] << 8) + (rgba[3]);
}

+ (UIColor *) colorWithRandomOpaque
{
	CGFloat red = nppRandomf(0.0f, 1.0f);
	CGFloat green = nppRandomf(0.0f, 1.0f);
	CGFloat blue = nppRandomf(0.0f, 1.0f);
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *) colorWithRandomTransparent
{
	CGFloat red = nppRandomf(0.0f, 1.0f);
	CGFloat green = nppRandomf(0.0f, 1.0f);
	CGFloat blue = nppRandomf(0.0f, 1.0f);
	CGFloat alpha = nppRandomf(0.0f, 1.0f);
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *) colorWithHexadecimalRGB:(unsigned int)hex
{
	CGFloat red = ((hex >> 16) & 0xFF) / 255.0f;
	CGFloat green = ((hex >> 8) & 0xFF) / 255.0f;
	CGFloat blue = ((hex >> 0) & 0xFF) / 255.0f;
	CGFloat alpha = 1.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *) colorWithHexadecimalRGBA:(unsigned int)hex
{
	CGFloat red = ((hex >> 24) & 0xFF) / 255.0f;
	CGFloat green = ((hex >> 16) & 0xFF) / 255.0f;
	CGFloat blue = ((hex >> 8) & 0xFF) / 255.0f;
	CGFloat alpha = ((hex >> 0) & 0xFF) / 255.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *) colorWithHexadecimalString:(NSString *)hex
{
	UIColor *color = nil;
	
	// Removing the Hexadecimal prefix.
	hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
	hex = [hex stringByReplacingOccurrencesOfString:@"0x" withString:@""];
	
	// Scan values.
	unsigned int hexadecimal;
	[[NSScanner scannerWithString:hex] scanHexInt:&hexadecimal];
	
	if ([hex length] > 6)
	{
		color = [self colorWithHexadecimalRGBA:hexadecimal];
	}
	else
	{
		color = [self colorWithHexadecimalRGB:hexadecimal];
	}
	
	return color;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end