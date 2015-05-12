/*
 *	NPPFont+UIFont.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/5/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

//TODO
#if NPP_IOS
	#define NPP_FONT				UIFont
#else
	#define NPP_FONT				NSFont
#endif

@interface UIFont(NPPFont)

// Main fonts.
- (UIFont *) nppFont;
- (UIFont *) nppFontWithSize:(CGFloat)pointSize;
+ (UIFont *) nppFontRegularWithSize:(CGFloat)pointSize;
+ (UIFont *) nppFontBoldWithSize:(CGFloat)pointSize;
+ (UIFont *) nppFontItalicWithSize:(CGFloat)pointSize;

+ (void) defineFontRegular:(NSString *)regular bold:(NSString *)bold italic:(NSString *)italic;
+ (void) defineFontAscender:(NSString *)fontName value:(CGFloat)value;

@end