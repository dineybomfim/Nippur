/*
 *	NPPInterfaceFunctions.m
 *	Nippur
 *	
 *	Created by Diney on 5/11/15.
 *	Copyright 2015 db-in. All rights reserved.
 */

#import "NPPInterfaceFunctions.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Device models.
#define NPP_STR_PAD					@"ipad"
#define NPP_STR_PHONE				@"iphone"
#define NPP_STR_POD					@"ipod"
#define NPP_STR_SIMULATOR			@"simulator"

#define NPP_STR_USER_AGENT			@"navigator.userAgent"
#define NPP_BUNDLE_BACKGROUND		@"UIBackgroundModes"

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

BOOL nppDeviceIsPad(void)
{
	/*
	NSString *model = [[[UIDevice currentDevice] model] lowercaseString];
	NSRange range = [model rangeOfString:NPP_STR_PAD];
	
	return (range.length > 0);
	/*/
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	//*/
}

BOOL nppDeviceIsPhone(void)
{
	NSString *model = [[[UIDevice currentDevice] model] lowercaseString];
	NSRange range = [model rangeOfString:NPP_STR_PHONE];
	
	return (range.length > 0);
}

BOOL nppDeviceIsPod(void)
{
	NSString *model = [[[UIDevice currentDevice] model] lowercaseString];
	NSRange range = [model rangeOfString:NPP_STR_POD];
	
	return (range.length > 0);
}

BOOL nppDeviceIsSimulator(void)
{
	NSString *model = [[[UIDevice currentDevice] model] lowercaseString];
	NSRange range = [model rangeOfString:NPP_STR_SIMULATOR];
	
	return (range.length > 0);
}

BOOL nppDeviceOrientationIsValid(void)
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	return !(orientation == UIDeviceOrientationUnknown ||
			 orientation == UIDeviceOrientationFaceUp ||
			 orientation == UIDeviceOrientationFaceDown);
}

BOOL nppDeviceOrientationIsPortrait(void)
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	return (orientation == UIDeviceOrientationPortrait ||
			orientation == UIDeviceOrientationPortraitUpsideDown);
}

BOOL nppDeviceOrientationIsLandscape(void)
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	return (orientation == UIDeviceOrientationLandscapeLeft ||
			orientation == UIDeviceOrientationLandscapeRight);
}

float nppDeviceOSVersion(void)
{
	static float osVersion = 0;
	
	if (osVersion == 0)
	{
		osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	}
	
	return osVersion;
}

BOOL nppDeviceSupportsBlur(void)
{
	static BOOL _default = NO;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^(void)
				  {
					  _default = (NSStringFromClass([UIVisualEffectView class]) &&
								  nppDeviceOSVersion() >= 8.0 &&
								  !UIAccessibilityIsReduceTransparencyEnabled());
				  });
	
	return _default;
}

CGRect nppDeviceScreenRectOriented(BOOL oriented)
{
	CGRect rect = [[UIScreen mainScreen] bounds];
	
	if (oriented)
	{
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		
		if (orientation == UIInterfaceOrientationIsPortrait(orientation))
		{
			rect = CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
		}
		else
		{
			rect = CGRectMake(0.0f, 0.0f, rect.size.height, rect.size.width);
		}
	}
	
	return rect;
}

NSString *nppApplicationWebUserAgent(void)
{
	static NSString *_default = nil;
	
	if (_default == nil)
	{
		UIWebView *webView = [[UIWebView alloc] init];
		_default = [webView stringByEvaluatingJavaScriptFromString:NPP_STR_USER_AGENT];
		nppRetain(_default);
		nppRelease(webView);
	}
	
	return _default;
}

BOOL nppApplicationHasBackgroundMode(NSString *backgroundMode)
{
	static NSArray *_default = nil;
	
	if (_default == nil)
	{
		_default = [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_BACKGROUND];
		nppRetain(_default);
	}
	
	return ([_default containsObject:backgroundMode]);
}

BOOL nppApplicationHasAnyBackgroundMode(void)
{
	static int _default = -1;
	
	if (_default == -1)
	{
		NSArray *modes = [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_BACKGROUND];
		_default = ([modes count] > 0);
	}
	
	return (BOOL)_default;
}

BOOL nppApplicationIsInBackground(void)
{
	UIApplicationState state = [[UIApplication sharedApplication] applicationState];
	return (state == UIApplicationStateBackground);
}