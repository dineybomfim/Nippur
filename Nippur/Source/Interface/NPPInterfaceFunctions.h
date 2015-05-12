/*
 *	NPPInterfaceFunctions.h
 *	Nippur
 *	
 *	Created by Diney on 5/11/15.
 *	Copyright 2015 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

// OS Versions
// These constants are to be used in runtime with the function nppDeviceOSVersion().

// This iOS version is necessary to use:
//	- GCD;
//	- Blocks;
//	- NSRegularExpression.
#define NPP_IOS_4_0					4.0f
#define NPP_IOS_4_1					4.1f
#define NPP_IOS_4_2					4.2f
#define NPP_IOS_4_3					4.3f

// This iOS version is necessary to use:
//	- 32 bits data type in shaders;
//	- Accelerate framework;
//	- Native Twitter account and API.
#define NPP_IOS_5_0					5.0f
#define NPP_IOS_5_1					5.1f

// This iOS version is necessary to use:
//	- Native Facebook account and API.
#define NPP_IOS_6_0					6.0f

// This iOS version is necessary to use:
//	- UIDynamics;
//	- iOS Custom transitions;
//	- SpriteKit;
//	- Translucent status bar.
#define NPP_IOS_7_0					7.0f
#define NPP_IOS_7_1					7.1f

// This iOS version is necessary to use:
//	- HelthKit;
//	- HomeKit;
//	- Watch.
#define NPP_IOS_8_0					8.0f
#define NPP_IOS_8_1					8.1f
#define NPP_IOS_8_2					8.2f
#define NPP_IOS_8_3					8.3f

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
NPP_API float nppDeviceOSVersion(void);
NPP_API BOOL nppDeviceSupportsBlur(void);

NPP_API CGRect nppDeviceScreenRectOriented(BOOL oriented);

NPP_API NSString *nppApplicationWebUserAgent(void);
NPP_API BOOL nppApplicationHasBackgroundMode(NSString *backgroundMode);
NPP_API BOOL nppApplicationHasAnyBackgroundMode(void);
NPP_API BOOL nppApplicationIsInBackground(void);