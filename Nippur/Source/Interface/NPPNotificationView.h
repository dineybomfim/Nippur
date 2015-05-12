/*
 *	NPPNotificationView.h
 *	Nippur
 *	v1.0
 *
 *	Created by Diney Bomfim on 10/4/13.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPStatusBar.h"
#import "NPPEffects.h"
#import "NPPWindow.h"

typedef enum
{
	NPPNotificationTypeInteractive,	// Default
	NPPNotificationTypeStatic,
} NPPNotificationType;

NPP_API UIImage *nppNotificationMark(CGRect frame, NPPDirection direction);

@interface NPPNotificationView : UIControl
{
@private
	// Basics
	NPPNotificationType			_type;
	float						_seconds;
	NPPBlockVoid				_block;
	
	// Effects
	UIView						*_viBackground;
	
	// iOS style
	UIView						*_viHolder;
	UILabel						*_lbTitle;
	UILabel						*_lbMessage;
	UIImageView					*_ivIcon;
	UIImageView					*_ivBackground;
}

@property (nonatomic, NPP_COPY) NSString *title;
@property (nonatomic, NPP_COPY) NSString *message;
@property (nonatomic, NPP_RETAIN) UIImage *icon;
@property (nonatomic) NPPNotificationType type;

- (void) setBlock:(NPPBlockVoid)block;
- (void) setCustomContent:(UIView *)view;

- (void) showWithDuration:(float)seconds animated:(BOOL)animated;
- (void) showAnimated:(BOOL)animated;
- (void) hideAnimated:(BOOL)animated;

+ (NPPNotificationView *) notificationGlobal;
+ (NPPNotificationView *) notificationWithCustomContent:(UIView *)view;
+ (NPPNotificationView *) notificationWithTitle:(NSString *)title
										message:(NSString *)message
										   time:(float)seconds;

@end