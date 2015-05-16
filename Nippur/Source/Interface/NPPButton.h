/*
 *	NPPButton.h
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
#import "NPPFont+UIFont.h"
#import "NPPImage+UIImage.h"

typedef NS_OPTIONS(NSUInteger, NPPButtonType)
{
	NPPButtonTypeBase,
	NPPButtonTypeKey,
	NPPButtonTypeKeyLeft,		// Shares the same image.
	NPPButtonTypeKeyRight,		// Shares the same image.
	NPPButtonTypeKeyMiddle,		// Shares the same image.
};

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