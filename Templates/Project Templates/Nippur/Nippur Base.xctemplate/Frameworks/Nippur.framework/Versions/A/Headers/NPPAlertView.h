/*
 *	NPPAlertView.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/18/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPLabel.h"
#import "NPPButton.h"
#import "NPPTextField.h"
#import "NPPWindowOverlay.h"

@interface NPPAlertView : UIScrollView
{
@private
	CGFloat					_width;
	CGFloat					_height;
	NSMutableArray			*_items;
	NPPLabel				*_lbTitle;
	NPPLabel				*_lbMessage;
	UIImageView				*_ivBackground;
}

@property (nonatomic) float margin;
@property (nonatomic) float space;
@property (nonatomic, NPP_COPY) NSString *title;
@property (nonatomic, NPP_COPY) NSString *message;
@property (nonatomic, NPP_RETAIN) UIImage *backgroundImage;

- (id) initWithTitle:(NSString *)title message:(NSString *)message;

- (void) addButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block;
- (void) addConfirmButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block;
- (void) addCancelButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block;
- (void) addButtonWithTitle:(NSString *)title
					  image:(NSString *)named
					  style:(NPPStyleColor)style
					  block:(NPPBlockVoid)block;

- (void) addViewItem:(UIView *)item;

- (void) show;
- (void) dismiss;

- (unsigned int) buttonsCount;

- (void) removeAllItems;
- (void) updateLayout;

+ (id) alertWithTitle:(NSString *)title message:(NSString *)message;

// Immediately shows unique alert.
+ (id) alerting:(NSString *)title message:(NSString *)message;
+ (id) alerting:(NSString *)title message:(NSString *)message done:(NSString *)done;

// Customizing.
+ (void) defineMargin:(float)margin andSpace:(float)space;
+ (void) defineBackgroundImageNamed:(NSString *)named;
+ (void) defineNativeAlerts:(BOOL)isNative;

@end
