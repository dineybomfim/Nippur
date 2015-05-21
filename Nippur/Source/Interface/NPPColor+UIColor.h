/*
 *	NPPColor+UIColor.h
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

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPInterfaceFunctions.h"

#import <UIKit/UIKit.h>

//TODO
#if NPP_IOS
	#define NPP_COLOR				UIColor
#else
	#define NPP_COLOR				NSColor
#endif

//TODO change vectors.
/*!
 *					Basic definition of a vector of order 4 based on float data type.
 *
 *	@var			NPPvec4::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *
 *	@var			NPPvec4::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NPPvec4::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 *
 *	@var			NPPvec4::w
 *					Represents the fourth component in a vector.
 *					You can use the letters "w", "a" or "q".
 */
typedef union
{
	struct { float x, y, z, w; };
	struct { float r, g, b, a; };
	struct { float s, t, p, q; };
} NPPvec4;

static const NPPvec4 kNPPvec4Zero = { 0.0f, 0.0f, 0.0f, 0.0f };

NPP_API NPPvec4 nppColorMake(float r, float g, float b, float a);
NPP_API NPPvec4 nppColorFromUIColor(UIColor *color);
NPP_API UIColor *nppColorToUIColor(NPPvec4 vec4);

/*!
 *					The RGBA color vector.
 *
 *	@var			NPPRGBA::r
 *					Red channel [0-255].
 *
 *	@var			NPPRGBA::g
 *					Green channel [0-255].
 *
 *	@var			NPPRGBA::b
 *					Blue channel [0-255].
 *
 *	@var			NPPRGBA::a
 *					Alpha channel [0-255].
 */
typedef struct
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} NPPRGBA;

static const NPPRGBA kNPPRGBAZero = { 0, 0, 0, 0 };

NPP_API NPPRGBA nppRGBAMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
NPP_API NPPRGBA nppRGBAFromUIColor(UIColor *color);
NPP_API UIColor *nppRGBAToUIColor(NPPRGBA rgba);

@interface UIColor(NPPColor)

- (unsigned int) hexadecimal;
- (unsigned int) hexadecimalRGBA;

+ (UIColor *) colorWithRandomOpaque;
+ (UIColor *) colorWithRandomTransparent;

+ (UIColor *) colorWithHexadecimalRGB:(unsigned int)hex;
+ (UIColor *) colorWithHexadecimalRGBA:(unsigned int)hex;
+ (UIColor *) colorWithHexadecimalString:(NSString *)hex;

@end