/*
 *	NPPNotificationView.h
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