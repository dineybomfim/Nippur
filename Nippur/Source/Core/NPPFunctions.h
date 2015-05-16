/*
 *	NPPFunctions.h
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
#import "NPPRegEx.h"

/*!
 *					Defines the direction of the transition.
 *
 *	@var			NPPDirectionUp
 *					Animation goes to up side of the screen.
 *
 *	@var			NPPDirectionRight
 *					Animation goes to right side of the screen.
 *
 *	@var			NPPDirectionDown
 *					Animation goes to down side of the screen.
 *
 *	@var			NPPDirectionLeft
 *					Animation goes to left side of the screen.
 */
typedef NS_OPTIONS(NSUInteger, NPPDirection)
{
	NPPDirectionUp,
	NPPDirectionRight,
	NPPDirectionDown,
	NPPDirectionLeft,
};

typedef NS_OPTIONS(NSUInteger, NPPStyleColor)
{
	NPPStyleColorLight,
	NPPStyleColorDark,
	NPPStyleColorConfirm,
	NPPStyleColorAlert,
};

typedef NS_OPTIONS(NSUInteger, NPPPosition)
{
	NPPPositionTop,
	NPPPositionRight,
	NPPPositionBottom,
	NPPPositionLeft,
};

typedef void (^NPPBlockVoid)(void);
typedef void (^NPPBlockInfo)(NPP_ARC_UNSAFE NSDictionary *info);
static const NSRange NPPRangeZero = { NSNotFound, 0 };

/*!
 *					Returns a random float value within the min and max values.
 *
 *	@param			min
 *					The minimum value.
 *
 *	@param			max
 *					The maximum value.
 *
 *	@result			The random float value.
 */
NPP_API float nppRandomf(float min, float max);

/*!
 *					Returns a random int value within the min and max values.
 *
 *	@param			min
 *					The minimum value.
 *
 *	@param			max
 *					The maximum value.
 *
 *	@result			The random int value.
 */
NPP_API int nppRandomi(int min, int max);

/*!
 *					Gets the localized string according to the Localized User Settings in the device.
 */
NPP_API NSString *nppS(NSString *string);

NPP_API NSString *nppGetFile(NSString *named);
NPP_API NSString *nppGetFileExtension(NSString *named);
NPP_API NSString *nppGetFileName(NSString *named);
NPP_API NSString *nppGetPath(NSString *named);
NPP_API NSString *nppMakePath(NSString *named);
NPP_API NSURL *nppMakeURL(NSString *named);

NPP_API NSString *nppStringFromFile(NSString *named);
NPP_API NSData *nppDataFromFile(NSString *named);

// XIB file must has the same name/class as the item.
NPP_API id nppItemFromXIB(NSString *name);
NPP_API BOOL nppFileExists(NSString *named);

NPP_API float nppPointsDistance(CGPoint pointA, CGPoint pointB);

NPP_API void nppPerformAction(id target, SEL action);

// Application level are retrieved once per run, because it can't change during run time.
NPP_API NSString *nppGetApplicationVersion(void);
NPP_API NSString *nppGetApplicationBuild(void);
NPP_API NSString *nppGetApplicationName(void);
NPP_API NSString *nppGetApplicationBundleID(void);

NPP_API NSString *nppGetLanguage(void);

// The file's name and the object must be the same, similar to ViewController approach.
NPP_API id nppGetBundleObject(NSString *name);

NPP_API NSString *nppGenerateHash(unsigned int size, BOOL canRepeat, BOOL canUpperCase);
NPP_API NSString *nppGenerateUUID(void); // Universal Unique Identifier (UUID).

NPP_API void nppSwizzle(Class aClass, SEL old, SEL newer);

// By default, it'll check for "beta". This function is always case insensitive.
NPP_API BOOL nppBetaCheck(void);
NPP_API void nppBetaSetString(NSString *betaString);