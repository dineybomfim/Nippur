/*
 *	NPPNotificationCenter+NSNotificationCenter.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 8/4/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"

NPP_API NSString *const kNPPNotificationAlertDidShow;
NPP_API NSString *const kNPPNotificationAlertDidHide;
NPP_API NSString *const kNPPNotificationActionSheetDidShow;
NPP_API NSString *const kNPPNotificationActionSheetDidHide;

@interface NSNotificationCenter (NPPNotificationCenter)

- (void) postMainNotification:(NSString *)name
					   object:(id)obj
					 userInfo:(NSDictionary *)info;

+ (void) defaultCenterPostMainNotification:(NSString *)name;
+ (void) defaultCenterPostMainNotification:(NSString *)name
									object:(id)obj
								  userInfo:(NSDictionary *)info;

@end