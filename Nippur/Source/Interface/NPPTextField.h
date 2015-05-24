/*
 *	NPPTextField.h
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com/nippur
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

#import "NPPPluginView.h"
#import "NPPPluginImage.h"
#import "NPPPluginFont.h"

typedef NS_OPTIONS(NSUInteger, NPPTextFieldState)
{
	NPPTextFieldStateNone,
	NPPTextFieldStateValid,
	NPPTextFieldStateInvalid,
};

@interface NPPTextField : UITextField
{
	UIColor					*_placeholderColor;
	
	NPPImage				*_iconImage;
	NPPImage				*_validIconImage;
	NPPImage				*_invalidIconImage;
	NPPTextFieldState		_textState;
	BOOL					_showTextState;
}

@property (nonatomic) int intText;
@property (nonatomic) float floatText;
@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic, NPP_RETAIN) UIColor *placeholderColor;
@property (nonatomic, NPP_RETAIN) NPPImage *iconImage;
@property (nonatomic, NPP_RETAIN) NPPImage *validIconImage;
@property (nonatomic, NPP_RETAIN) NPPImage *invalidIconImage;
@property (nonatomic) NPPTextFieldState textState;
@property (nonatomic) BOOL showTextState; // Default is YES

+ (id) textFieldWithFrame:(CGRect)frame;

- (void) setTextState:(NPPTextFieldState)state animated:(BOOL)animated;

+ (void) defineTextFieldEdgeInsets:(UIEdgeInsets)value;
+ (void) defineValidIconImage:(NPPImage *)valid invalidIconImage:(NPPImage *)invalid;

@end