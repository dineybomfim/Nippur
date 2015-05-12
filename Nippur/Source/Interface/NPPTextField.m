/*
 *	NPPTextField.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/13/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPTextField.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_CLEAR_SIZE				26.0f
#define NPP_FIELD_VALID				@"npp_icon_status_green.png"
#define NPP_FIELD_INVALID			@"npp_icon_status_red.png"

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static UIEdgeInsets _defaultEdge = (UIEdgeInsets){ 0.0f, 0.0f, 0.0f, 0.0f };
NPP_ARC_RETAIN static NPPImage *_defaultValidIcon = nil;
NPP_ARC_RETAIN static NPPImage *_defaultInvalidIcon = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static CGRect nppTextFieldRectWithEdges(CGRect fieldBounds, CGRect rect, UIEdgeInsets edges, BOOL clear)
{
	// First finds the final bounds with edge insets.
	// +-----+
	// |+---+|
	// ||   ||
	// |+---+|
	// +-----+
	fieldBounds.origin.x += edges.left;
	fieldBounds.origin.y += edges.top;
	fieldBounds.size.width -= edges.left + edges.right + NPP_CLEAR_SIZE;//((clear) ? NPP_CLEAR_SIZE : 0.0f);
	fieldBounds.size.height -= edges.top + edges.bottom;
	
	// Makes sure the rect will not exceed any of the final bounds.
	rect.origin.x = MAX(rect.origin.x, fieldBounds.origin.x);
	rect.origin.y = MAX(rect.origin.y, fieldBounds.origin.y);
	rect.size.width = MIN(rect.size.width, fieldBounds.size.width - rect.origin.x);
	rect.size.height = MIN(rect.size.height, fieldBounds.size.height - rect.origin.y);
	
	return rect;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPTextField()

// Initializes a new instance.
- (void) initializing;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPTextField

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize edgeInsets = _edgeInsets;

@dynamic intText, floatText, placeholderColor, iconImage, validIconImage, invalidIconImage,
		 textState, showTextState;

- (int) intText { return [[self text] intValue]; }
- (void) setIntText:(int)value
{
	NSString *string = [NSString stringWithFormat:@"%i",value];
	self.text = string;
}

- (float) floatText { return [[[self text] stringByReplacingOccurrencesOfString:@","
																	 withString:@"."] floatValue]; }
- (void) setFloatText:(float)value
{
	NSString *string = [NSString stringWithFormat:@"%.2f", value];
	self.text = [string stringByReplacingOccurrencesOfString:@"."
												  withString:@","];
}

- (UIColor *) placeholderColor { return _placeholderColor; }
- (void) setPlaceholderColor:(UIColor *)value
{
	nppRelease(_placeholderColor);
	_placeholderColor = nppRetain(value);
	
	[self setValue:_placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (NPPImage *) iconImage { return _iconImage; }
- (void) setIconImage:(NPPImage *)value
{
	nppRelease(_iconImage);
	_iconImage = nppRetain(value);
	
	UIImageView *ivIcon = [[UIImageView alloc] initWithImage:value];
	self.leftView = ivIcon;
	self.leftViewMode = UITextFieldViewModeAlways;
	nppRelease(ivIcon);
}

- (NPPImage *) validIconImage { return _validIconImage; }
- (void) setValidIconImage:(NPPImage *)value
{
	nppRelease(_validIconImage);
	_validIconImage = nppRetain(value);
}

- (NPPImage *) invalidIconImage { return _invalidIconImage; }
- (void) setInvalidIconImage:(NPPImage *)value
{
	nppRelease(_invalidIconImage);
	_invalidIconImage = nppRetain(value);
}

- (NPPTextFieldState) textState { return _textState; }
- (void) setTextState:(NPPTextFieldState)value
{
	[self setTextState:value animated:NO];
}

- (BOOL) showTextState { return _showTextState; }
- (void) setShowTextState:(BOOL)value
{
	_showTextState = value;
	
	self.rightViewMode = (_showTextState) ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializing];
		
		// Background image will be 9-sliced.
		UIImage *background = self.background;
		background = [background imageNineSliced];
		
		// Make localizable text.
		[self setText:nppS(self.text)];
		[self setPlaceholder:nppS(self.placeholder)];
		[self setBackground:background];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializing];
	}
	
	return self;
}

+ (id) textFieldWithFrame:(CGRect)frame
{
	NPPTextField *textField = [[self alloc] initWithFrame:frame];
	
	return nppAutorelease(textField);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	_showTextState = YES;
	_edgeInsets = _defaultEdge;
	self.placeholderColor = [UIColor colorWithHexadecimalRGB:0xE0E0E0];
	self.font = [self.font nppFont];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) setTextState:(NPPTextFieldState)state animated:(BOOL)animated
{
	// Avoid repeating the same state.
	if (_textState == state || !_showTextState)
	{
		return;
	}
	
	_textState = state;
	
	NPPDirection direction = NPPDirectionRight;
	__block UIView *ivGoingOut = self.rightView;
	__block UIImageView *ivGoingIn = nil;
	NPPAction *actionIn = nil;
	NPPImage *newIcon = nil;
	NSString *coordinate = nil;
	CGSize size = self.size;
	float finalPos = 0.0f;
	NPPBlockVoid completion = nil;
	
	// Try to get the instance icon first, then try the global definition.
	// If none was set, it will use the framework default.
	switch (state)
	{
		case NPPTextFieldStateValid:
			newIcon = (_validIconImage != nil) ? _validIconImage : _defaultValidIcon;
			newIcon = (newIcon != nil) ? newIcon : (NPPImage *)nppImageFromFile(NPP_FIELD_VALID);
			break;
		case NPPTextFieldStateInvalid:
			newIcon = (_invalidIconImage != nil) ? _invalidIconImage : _defaultInvalidIcon;
			newIcon = (newIcon != nil) ? newIcon : (NPPImage *)nppImageFromFile(NPP_FIELD_INVALID);
			break;
		default:
			break;
	}
	
	// Initializing and calculating the final position for the new right view.
	ivGoingIn = [[UIImageView alloc] initWithImage:newIcon];
	[ivGoingIn centerYInView:self];
	ivGoingIn.x = size.width - ivGoingIn.width - _edgeInsets.right;
	[self addSubview:ivGoingIn];
	
	// The direction available are up, right and down only.
	// Left is taken as right, which is the default.
	switch (direction)
	{
		case NPPDirectionUp:
			coordinate = @"y";
			finalPos = -MAX(ivGoingIn.height, ivGoingOut.height);
			break;
		case NPPDirectionDown:
			coordinate = @"y";
			finalPos = size.height;
			break;
		default:
			coordinate = @"x";
			finalPos = size.width;
			break;
	}
	
	completion = ^(void)
	{
		[ivGoingIn removeFromSuperview];
		self.rightView = ivGoingIn;
		self.rightViewMode = UITextFieldViewModeAlways;
		nppRelease(ivGoingIn);
	};
	
	if (!animated)
	{
		nppBlock(completion);
	}
	else
	{
		actionIn = [NPPAction moveKey:coordinate from:finalPos duration:kNPPAnimTimeX2];
		actionIn.ease = NPPActionEaseBounceOut;
		
		[ivGoingOut runAction:[NPPAction moveKey:coordinate to:finalPos duration:kNPPAnimTime]];
		[ivGoingIn runAction:actionIn completion:completion];
	}
}

+ (void) defineTextFieldEdgeInsets:(UIEdgeInsets)value
{
	_defaultEdge = value;
}

+ (void) defineValidIconImage:(NPPImage *)valid invalidIconImage:(NPPImage *)invalid
{
	nppRelease(_defaultValidIcon);
	nppRelease(_defaultInvalidIcon);
	_defaultValidIcon = nppRetain(valid);
	_defaultInvalidIcon = nppRetain(invalid);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (CGRect) textRectForBounds:(CGRect)bounds
{
	BOOL clear = (self.clearButtonMode == UITextFieldViewModeAlways);
	CGRect rect = [super textRectForBounds:bounds];
	rect = nppTextFieldRectWithEdges(bounds, rect, _edgeInsets, clear);
	
	// Bar trick.
	if (nppDeviceOSVersion() < 7.0f)
	{
		rect.origin.y += 20.0f;
	}
	
	return rect;
}

- (CGRect) editingRectForBounds:(CGRect)bounds
{
	BOOL clear = (self.clearButtonMode == UITextFieldViewModeWhileEditing);
	CGRect rect = [super editingRectForBounds:bounds];
	rect = nppTextFieldRectWithEdges(bounds, rect, _edgeInsets, clear);
	
	// Bar trick.
	if (nppDeviceOSVersion() < 7.0f)
	{
		rect.origin.y += 20.0f;
	}
	
	return rect;
}

- (CGRect) placeholderRectForBounds:(CGRect)bounds
{
	BOOL clear = (self.clearButtonMode == UITextFieldViewModeAlways);
	CGRect rect = [super placeholderRectForBounds:bounds];
	rect = nppTextFieldRectWithEdges(bounds, rect, _edgeInsets, clear);
	
	return rect;
}

- (CGRect) leftViewRectForBounds:(CGRect)bounds
{
	CGRect rect = [super leftViewRectForBounds:bounds];
	rect.origin.x += _edgeInsets.left;
	rect.origin.y += _edgeInsets.top;
	
	return rect;
}

- (CGRect) rightViewRectForBounds:(CGRect)bounds
{
	CGRect rect = [super rightViewRectForBounds:bounds];
	rect.origin.x -= _edgeInsets.right;
	rect.origin.y += _edgeInsets.top;
	
	return rect;
}
//*
- (CGRect) clearButtonRectForBounds:(CGRect)bounds
{
	CGRect rect = [super clearButtonRectForBounds:bounds];
	rect.origin.x -= _edgeInsets.right;
	
	return rect;
}
//*/
- (void) dealloc
{
	nppRelease(_placeholderColor);
	nppRelease(_iconImage);
	nppRelease(_validIconImage);
	nppRelease(_invalidIconImage);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
