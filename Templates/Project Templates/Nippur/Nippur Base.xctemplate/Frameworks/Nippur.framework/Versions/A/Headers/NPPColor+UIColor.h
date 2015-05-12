/*
 *	NPPColor+UIColor.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/2/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

//TODO
#if NPP_IOS
	#define NPP_COLOR				UIColor
#else
	#define NPP_COLOR				NSColor
#endif

//TODO change vectors.
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