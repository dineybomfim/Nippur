/*
 *	NPPButton.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 2/28/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPLabel.h"
#import "NPPFont+UIFont.h"
#import "NPPImage+UIImage.h"

typedef enum
{
	NPPButtonTypeBase,
	NPPButtonTypeKey,
	NPPButtonTypeKeyLeft,		// Shares the same image.
	NPPButtonTypeKeyRight,		// Shares the same image.
	NPPButtonTypeKeyMiddle,		// Shares the same image.
} NPPButtonType;

@interface NPPButton : UIButton
{
@private
	NPPButtonType				_type;
	NPPStyleColor				_styleColor;
	NPPBlockVoid				_block;
}

@property (nonatomic, readonly) NPPButtonType type;
@property (nonatomic, readonly) NPPStyleColor styleColor;

- (id) initWithTitle:(NSString *)title
			   image:(NSString *)named
				type:(NPPButtonType)type
			   style:(NPPStyleColor)style;

+ (id) buttonWithTitle:(NSString *)title
				 image:(NSString *)named
				  type:(NPPButtonType)type
				 style:(NPPStyleColor)style;

- (void) setType:(NPPButtonType)type andStyle:(NPPStyleColor)style;
- (void) setTarget:(id)aTarget action:(SEL)aSelector;
- (void) setBlock:(NPPBlockVoid)block;

// The pattern is <named>_<color-optional>_<state-optional>
// EX
// Files: myCustomButton_dark_up.png, myCustomButton_dark_down.png
// Call: defineBackgroundImageNamed:myCustomButton.png forType:NPPButtonTypeKey;
+ (void) defineBackground:(NSString *)imageNamed type:(NPPButtonType)type style:(NPPStyleColor)style;

@end