/*
 *	NPPNotificationCenter+NSNotificationCenter.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 8/4/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPNotificationCenter+NSNotificationCenter.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

NSString *const kNPPNotificationAlertDidShow		= @"kNPPNotificationAlertDidShow";
NSString *const kNPPNotificationAlertDidHide		= @"kNPPNotificationAlertDidHide";
NSString *const kNPPNotificationActionSheetDidShow	= @"kNPPNotificationActionSheetDidShow";
NSString *const kNPPNotificationActionSheetDidHide	= @"kNPPNotificationActionSheetDidHide";

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
#pragma mark NPPNotificationCenter
#pragma mark -
//**********************************************************************************************************
//
//	NPPNotificationCenter
//
//**********************************************************************************************************

@implementation NSNotificationCenter (NPPNotificationCenter)

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

- (void) postMainNotification:(NSString *)name object:(id)obj userInfo:(NSDictionary *)info
{
	if (![NSThread isMainThread])
	{
		NPPBlockVoid block = ^(void)
		{
			[self postNotificationName:name object:obj userInfo:info];
		};
		
		nppBlockMain(block);
	}
	else
	{
		[self postNotificationName:name object:obj userInfo:info];
	}
}

+ (void) defaultCenterPostMainNotification:(NSString *)name
{
	[[NSNotificationCenter defaultCenter] postMainNotification:name object:nil userInfo:nil];
}

+ (void) defaultCenterPostMainNotification:(NSString *)name object:(id)obj userInfo:(NSDictionary *)info
{
	[[NSNotificationCenter defaultCenter] postMainNotification:name object:obj userInfo:info];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end