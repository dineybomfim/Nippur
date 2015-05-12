/*
 *	NPPFunctions.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/15/12.
 *	Copyright 2012 db-in. All rights reserved.
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
typedef enum
{
	NPPDirectionUp,
	NPPDirectionRight,
	NPPDirectionDown,
	NPPDirectionLeft,
} NPPDirection;

typedef enum
{
	NPPStyleColorLight,
	NPPStyleColorDark,
	NPPStyleColorConfirm,
	NPPStyleColorAlert,
} NPPStyleColor;

typedef enum
{
	NPPPositionTop,
	NPPPositionRight,
	NPPPositionBottom,
	NPPPositionLeft,
} NPPPosition;

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