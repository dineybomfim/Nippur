/*
 *	NPPTextField.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/13/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPImage+UIImage.h"
#import "NPPFont+UIFont.h"

typedef enum
{
	NPPTextFieldStateNone,
	NPPTextFieldStateValid,
	NPPTextFieldStateInvalid,
} NPPTextFieldState;

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