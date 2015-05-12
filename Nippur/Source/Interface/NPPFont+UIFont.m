/*
 *	NPPFont+UIFont.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/5/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPFont+UIFont.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Default fonts.
#define NPP_FONT_REGULAR			@"Helvetica"
#define NPP_FONT_BOLD				@"Helvetica-Bold"
#define NPP_FONT_ITALIC				@"Helvetica-Oblique"

// Parameters.
#define NPP_FONT_ASCENDER			@"ascender"
#define NPP_FONT_DESCENDER			@"descender"
#define NPP_FONT_LEADING			@"leading"
#define NPP_FONT_CAP_HEIGHT			@"capHeight"
#define NPP_FONT_X_HEIGHT			@"xHeight"

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Variables
//**************************************************
//	Private Variables
//**************************************************

// Font variables.
static NSString *_nppRegularFont = nil;
static NSString *_nppBoldFont = nil;
static NSString *_nppItalicFont = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(getFontDict, NSMutableDictionary);

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

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

@implementation UIFont (NPPFont)

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

- (UIFont *) nppFont
{
	return [self nppFontWithSize:self.pointSize];
}

- (UIFont *) nppFontWithSize:(CGFloat)pointSize
{
	NSString *fontName = self.fontName;
	UIFont *font = nil;
	
	if ([fontName isEqualToString:_nppBoldFont] ||
		[fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].length > 0 ||
		[fontName rangeOfString:@"medium" options:NSCaseInsensitiveSearch].length > 0)
	{
		font = [UIFont nppFontBoldWithSize:pointSize];
	}
	else if ([fontName isEqualToString:_nppItalicFont] ||
			 [fontName rangeOfString:@"italic" options:NSCaseInsensitiveSearch].length > 0 ||
			 [fontName rangeOfString:@"oblique" options:NSCaseInsensitiveSearch].length > 0)
	{
		font = [UIFont nppFontItalicWithSize:pointSize];
	}
	else
	{
		font = [UIFont nppFontRegularWithSize:pointSize];
	}
	
	return font;
}

+ (UIFont *) nppFontRegularWithSize:(CGFloat)pointSize
{
	NSString *fontName = (_nppRegularFont != nil) ? _nppRegularFont : NPP_FONT_REGULAR;
	return [UIFont fontWithName:fontName size:pointSize];
}

+ (UIFont *) nppFontBoldWithSize:(CGFloat)pointSize
{
	NSString *fontName = (_nppBoldFont != nil) ? _nppBoldFont : NPP_FONT_BOLD;
	return [UIFont fontWithName:fontName size:pointSize];
}

+ (UIFont *) nppFontItalicWithSize:(CGFloat)pointSize
{
	NSString *fontName = (_nppItalicFont != nil) ? _nppItalicFont : NPP_FONT_ITALIC;
	return [UIFont fontWithName:fontName size:pointSize];
}

+ (void) defineFontRegular:(NSString *)regular bold:(NSString *)bold italic:(NSString *)italic
{
	nppRelease(_nppRegularFont);
	nppRelease(_nppBoldFont);
	nppRelease(_nppItalicFont);
	
	_nppRegularFont = [regular copy];
	_nppBoldFont = [bold copy];
	_nppItalicFont = [italic copy];
}

+ (void) defineFontAscender:(NSString *)fontName value:(CGFloat)value
{
	NSMutableDictionary *properties = [getFontDict() objectForKey:fontName];
	
	if (properties == nil)
	{
		properties = [NSMutableDictionary dictionary];
		[getFontDict() setObject:properties forKey:fontName];
	}
	
	[properties setObject:[NSNumber numberWithFloat:value] forKey:NPP_FONT_ASCENDER];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************
/*
- (CGFloat) ascender
{
	NSString *fontName = self.fontName;
	NSNumber *number;
	float ascender;
	
	if ((number = [[getFontDict() objectForKey:fontName] objectForKey:NPP_FONT_ASCENDER]))
	{
		ascender = [number floatValue];
	}
	else
	{
		CGFontRef cgFont = CGFontCreateWithFontName((NPP_ARC_BRIDGE CFStringRef)fontName);
		ascender = ((self.pointSize / CGFontGetUnitsPerEm(cgFont)) * CGFontGetAscent(cgFont)) * 1.25f;
		ascender *= 1.115f;
		CGFontRelease(cgFont);
	}
	
	return ascender;
}
//*/
/*
- (CGFloat) descender
{
	CGFontRef cgFont = CGFontCreateWithFontName((NPP_ARC_BRIDGE CFStringRef)self.fontName);
	float descender  = floorf((self.pointSize / CGFontGetUnitsPerEm(cgFont)) * CGFontGetDescent(cgFont));
	CGFontRelease(cgFont);
	
	return descender;
}

- (CGFloat) leading
{
	return (self.ascender - self.descender);
}

- (CGFloat) capHeight
{
	CGFontRef cgFont = CGFontCreateWithFontName((NPP_ARC_BRIDGE CFStringRef)self.fontName);
	float capHeight  = ceilf((self.pointSize / CGFontGetUnitsPerEm(cgFont)) * CGFontGetCapHeight(cgFont));
	CGFontRelease(cgFont);
	
	return capHeight;
}

- (CGFloat) xHeight
{
	CGFontRef cgFont = CGFontCreateWithFontName((NPP_ARC_BRIDGE CFStringRef)self.fontName);
	float xHeight  = ceilf((self.pointSize / CGFontGetUnitsPerEm(cgFont)) * CGFontGetXHeight(cgFont));
	CGFontRelease(cgFont);
	
	return xHeight;
}
//*/
@end