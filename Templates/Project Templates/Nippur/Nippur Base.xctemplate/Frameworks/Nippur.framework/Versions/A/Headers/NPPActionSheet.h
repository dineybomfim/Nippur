/*
 *	NPPActionSheet.h
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

typedef enum
{
	NPPActionSheetStyleDefault,
	NPPActionSheetStyleList,
	NPPActionSheetStyleIcons,
} NPPActionSheetStyle;

@interface NPPActionSheet : UIView
{
@private
	NSMutableArray					*_blocks;
	CGFloat							_height;
}

@property (nonatomic) float margin;
@property (nonatomic) float space;
@property (nonatomic) NPPActionSheetStyle style;
@property (nonatomic) unsigned int iconsPerLine;
@property (nonatomic, NPP_RETAIN) UIImage *backgroundImage;

- (id) initWithTitle:(NSString *)title;

- (void) addButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block;
- (void) addConfirmButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block;
- (void) addCancelButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block;
- (void) addButtonWithTitle:(NSString *)title
					  image:(NSString *)named
					  style:(NPPStyleColor)style
					  block:(NPPBlockVoid)block;

- (void) show;
- (void) dismiss;

- (unsigned int) buttonsCount;

+ (id) sheetWithTitle:(NSString *)title;

// Customizing.
+ (void) defineMargin:(float)margin andSpace:(float)space;
+ (void) defineBackgroundImageNamed:(NSString *)named;

@end