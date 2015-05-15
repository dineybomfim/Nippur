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
 *					Represents a direction.
 *
 *	@var			NPPDirectionUp
 *					It represents the up side.
 *
 *	@var			NPPDirectionRight
 *					It represents the right side.
 *
 *	@var			NPPDirectionDown
 *					It represents the down side.
 *
 *	@var			NPPDirectionLeft
 *					It represents the left side.
 */
typedef NS_OPTIONS(NSUInteger, NPPDirection)
{
	NPPDirectionUp,
	NPPDirectionRight,
	NPPDirectionDown,
	NPPDirectionLeft,
};

/*!
 *					Definition of a block with no arguments.
 */
typedef void (^NPPBlockVoid)(void);

/*!
 *					Definition of a block with one non-retained dictionary as argument.
 */
typedef void (^NPPBlockInfo)(NPP_ARC_UNSAFE NSDictionary *info);

/*!
 *					Definition of the range with zero values.
 */
static const NSRange NPPRangeZero = { NSNotFound, 0 };

//*************************
//	Math Functions
//*************************

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
 *					Returns the modular distance between two points.
 *
 *	@param			pointA
 *					The first point.
 *
 *	@param			max
 *					The second point.
 *
 *	@result			The modular distance between points. It is always positive.
 */
NPP_API float nppPointsDistance(CGPoint pointA, CGPoint pointB);

//*************************
//	Path Functions
//*************************

NPP_API NSString *nppGetFile(NSString *named);
NPP_API NSString *nppGetFileExtension(NSString *named);
NPP_API NSString *nppGetFileName(NSString *named);
NPP_API NSString *nppGetPath(NSString *named);
NPP_API NSString *nppMakePath(NSString *named);
NPP_API BOOL nppFileExists(NSString *named);
NPP_API id nppItemFromXIB(NSString *name); // XIB file must has the same name/class as the item.

//*************************
//	Bundle Functions
//*************************

// Bundle functions are optimized to run once per run, because it can't change during run time.
NPP_API NSString *nppGetBundleVersion(void);
NPP_API NSString *nppGetBundleBuild(void);
NPP_API NSString *nppGetBundleName(void);
NPP_API NSString *nppGetBundleID(void);

//*************************
//	Localized Functions
//*************************

/*!
 *					Gets the localized string according to the Localized User Settings in the device.
 *
 *	@param			string
 *					The string constant in the text file.
 *
 *	@result			An autoreleased string with the localized text for the informed constant.
 */
NPP_API NSString *nppS(NSString *string);

/*!
 *					Gets the preferred user language, including the country code based on User Settings.
 *
 *	@result			An autoreleased string with the language code.
 */
NPP_API NSString *nppGetLanguage(void);

//*************************
//	Utils Functions
//*************************

/*!
 *					This function performs an action on a target safely.
 *
 *	@param			target
 *					The object in which the action will be performed.
 *
 *	@param			action
 *					The selector to perform.
 */
NPP_API void nppPerformAction(id target, SEL action);

/*!
 *					Gets the localized string according to the Localized User Settings in the device.
 *
 *	@param			size
 *					The number of characters to generate (length).
 *
 *	@param			canRepeat
 *					It defines if the characters can repeat or not.
 *
 *	@param			canUpperCase
 *					It defines if the characters can be in upper case of if it'll be all lower case.
 *
 *	@result			An autoreleased string with the generated hash.
 */
NPP_API NSString *nppGenerateHash(unsigned int size, BOOL canRepeat, BOOL canUpperCase);

/*!
 *					Generates a hash in the Universal Unique Identifier (UUID) format:
 *						- (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)
 *
 *	@result			An autoreleased string with the generated hash.
 */
NPP_API NSString *nppGenerateUUID(void);

/*!
 *					This function swizzles two methods of a class. Use this function wisely.
 *					It's reversible, but once you made a change, you must remember that the methods
 *					are already swapped.
 *
 *	@param			class
 *					The target class that will swizzle methods.
 *
 *	@param			old
 *					The old selector.
 *
 *	@param			new
 *					The new selector.
 */
NPP_API void nppSwizzle(Class aClass, SEL old, SEL newer);

//*************************
//	Beta API
//*************************

/*!
 *					This function is part of the Beta Control API is very useful to control many
 *					things on your application safely.
 *
 *					It is in a safe way to set conditional things bound to the application certificate,
 *					more specifically to your application Bundle Identifier. To avoid uploading
 *					"BETA" stuff to the stores, you can define a special portion to your Bundle ID,
 *					like: com.mycompany.MyApp-Beta.
 *
 *					By default, this API assumes "beta" (case insensitive) as the Beta String.
 *
 *					Why is this API good?
 *						- You're not bound to a provisioning profile;
 *						- You're not bound to arch (simulator or device);
 *						- You have full control over all the variables in this way;
 *						- You don't need to worry about releasing a "BETA" stuff by mistake;
 *						- You can change it any time during the runtime.
 *
 *	@result			A BOOL indicating if the BETA is active or not.
 */
NPP_API BOOL nppBetaCheck(void);

/*!
 *					This function is part of the Beta Control API is very useful to control many
 *					things on your application safely.
 *
 *					Here you can define the Beta String, which is a portion of the application Bundle ID
 *					that will be used to consider it a "BETA".
 *
 *	@param			betaString
 *					The string which will be considered the "BETA" portion.
 */
NPP_API void nppBetaSetString(NSString *betaString);