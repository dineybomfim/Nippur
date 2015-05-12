/*
 *	NPPAlertView.h
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
