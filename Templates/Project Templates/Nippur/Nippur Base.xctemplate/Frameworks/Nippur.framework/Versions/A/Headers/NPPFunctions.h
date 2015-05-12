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

typedef struct
{
	NPP_ARC_UNSAFE id target;
	SEL action;
} NPPTargetAction;

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
 *					Checks if the current device is an iPad or not.
 *
 *	@result			A BOOL indicating if the current device is an iPad.
 */
NPP_API BOOL nppDeviceIsPad(void);

/*!
 *					Checks if the current device is an iPhone or not.
 *
 *	@result			A BOOL indicating if the current device is an iPhone.
 */
NPP_API BOOL nppDeviceIsPhone(void);

/*!
 *					Checks if the current device is an iPod or not.
 *
 *	@result			A BOOL indicating if the current device is an iPod.
 */
NPP_API BOOL nppDeviceIsPod(void);

/*!
 *					Checks if the current device is the simulator or not.
 *
 *	@result			A BOOL indicating if the current device is the simulator.
 */
NPP_API BOOL nppDeviceIsSimulator(void);

/*!
 *					Checks if the current device orientation is a valid one. Invalid orientations are:
 *					Unkown, FaceUp and FaceDown. All the other orientations are valid.
 *
 *	@result			A BOOL indicating if the current device orientation is valid.
 */
NPP_API BOOL nppDeviceOrientationIsValid(void);

/*!
 *					Checks if the current device orientation is a valid one. Invalid orientations are:
 *					Unkown, FaceUp and FaceDown. All the other orientations are valid.
 *
 *	@result			A BOOL indicating if the current device orientation is valid.
 */
NPP_API BOOL nppDeviceOrientationIsPortrait(void);

/*!
 *					Checks if the current device orientation is a valid one. Invalid orientations are:
 *					Unkown, FaceUp and FaceDown. All the other orientations are valid.
 *
 *	@result			A BOOL indicating if the current device orientation is valid.
 */
NPP_API BOOL nppDeviceOrientationIsLandscape(void);

/*!
 *					Returns the current version of the running OS. The result should be compared to
 *					a NPP_IOS_X_X definition.
 *
 *	@result			A float with the version of the running OS.
 */
NPP_API float nppSystemVersion(void);

/*!
 *					Checks if the running OS is Pad(iPad) interface.
 *
 *	@result			A BOOL indicating if the current system is Pad version.
 */
NPP_API BOOL nppSystemIsPadIdiom(void);

/*!
 *					Checks if the running OS is Phone(iPhone and iPod) interface.
 *
 *	@result			A BOOL indicating if the current system is Phone version.
 */
NPP_API BOOL nppSystemIsPhoneIdiom(void);
NPP_API BOOL nppSystemSupportsBlur(void);

NPP_API float nppKeyboardHeight(UIInterfaceOrientation orientation);

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
NPP_API UIImage *nppImageFromFile(NSString *named);
NPP_API NSArray *nppImagesFromFiles(NSString *namePattern);

// Single name or numeric # pattern. Starting at #1.
NPP_API UIImageView *nppImageViewFromFile(NSString *namePattern);

// XIB file must has the same name/class as the item.
NPP_API id nppItemFromXIB(NSString *name);

NPP_API BOOL nppFileExists(NSString *named);

NPP_API float nppPointsDistance(CGPoint pointA, CGPoint pointB);
NPP_API CGRect nppGetScreenRectOriented(BOOL oriented);

NPP_API void nppPerformAction(id target, SEL action);
NPP_API NPPTargetAction nppGetTargetActionFromGesture(UIGestureRecognizer *gesture);

// Application level are retrieved once per run, because it can't change during run time.
NPP_API NSString *nppGetApplicationVersion(void);
NPP_API NSString *nppGetApplicationBuild(void);
NPP_API NSString *nppGetApplicationName(void);
NPP_API NSString *nppGetApplicationBundleID(void);
NPP_API NSString *nppGetApplicationWebUserAgent(void);
NPP_API BOOL nppApplicationHasBackgroundMode(NSString *backgroundMode);
NPP_API BOOL nppApplicationHasAnyBackgroundMode(void);
NPP_API BOOL nppApplicationIsInBackground(void);

NPP_API NSString *nppGetLanguage(void);

// The file's name and the object must be the same, similar to ViewController approach.
NPP_API id nppGetBundleObject(NSString *name);

NPP_API NSString *nppGenerateHash(unsigned int size, BOOL canRepeat, BOOL canUpperCase);
NPP_API NSString *nppGenerateUUID(void); // Universal Unique Identifier (UUID).

NPP_API void nppSwizzle(Class aClass, SEL old, SEL newer);

// Indicates if the context was created. Must call UIGraphicsEndImageContext(); to finish the context.
NPP_API BOOL nppGraphicsBeginImageContext(CGSize size, BOOL opaque, float scale);

// By default, it'll check for "beta". This function is always case insensitive.
NPP_API BOOL nppBetaCheck(void);
NPP_API void nppBetaSetString(NSString *betaString);
