/*
 *	NPPLabel.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 2/28/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPLabel.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_LABEL_MAX_HEIGHT			2048.0f

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

static UIEdgeInsets _defaultEdgeInsets = (UIEdgeInsets){ 0.0f, 0.0f, 0.0f, 0.0f };

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static CGRect nppLabelRectWithEdges(CGRect fieldBounds, CGRect rect, UIEdgeInsets edges)
{
	// First finds the final bounds with edge insets.
	// +-----+
	// |+---+|
	// ||   ||
	// |+---+|
	// +-----+
	fieldBounds.origin.x += edges.left;
	fieldBounds.origin.y += edges.top;
	fieldBounds.size.width -= edges.left + edges.right;
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

@interface NPPLabel()

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

@implementation NPPLabel

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize edgeInsets = _edgeInsets;

@dynamic intText, floatText;

- (int) intText { return [[self text] intValue]; }
- (void) setIntText:(int)value
{
	NSString *string = [NSString stringWithFormat:@"%i",value];
	self.text = string;
}

- (float) floatText { return [[self text] floatValue]; }
- (void) setFloatText:(float)value
{
	NSString *string = [NSString stringWithFormat:@"%.2f",value];
	self.text = [string stringByReplacingOccurrencesOfString:@"." withString:@","];
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
		
		// Make localizable text.
		[self setText:nppS(self.text)];
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

- (id) initWithCenterString:(NSString *)string font:(UIFont *)font maxWidth:(float)width
{
	CGRect frame = nppDeviceScreenRectOriented(YES);
	width = (width > 0) ? width : frame.size.width;
	
	CGSize size = [string sizeWithFont:font
						   constrained:CGSizeMake(width, NPP_LABEL_MAX_HEIGHT)
							 lineBreak:NSLineBreakByWordWrapping];
	
	if ((self = [super initWithFrame:CGRectMake(0, 0, width, MAX(font.lineHeight, size.height))]))
	{
		[self initializing];
		
		self.font = font;
		self.lineBreakMode = NSLineBreakByWordWrapping;
		self.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor clearColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.numberOfLines = 0;
		self.text = string;
	}
	
	return self;
}

+ (id) labelRegular:(NSString *)title fontSize:(float)pointSize maxWidth:(float)width
{
	NPPLabel *labelView = [[self alloc] initWithCenterString:title
														font:[UIFont nppFontRegularWithSize:pointSize]
													maxWidth:width];
	
	return nppAutorelease(labelView);
}

+ (id) labelBold:(NSString *)title fontSize:(float)pointSize maxWidth:(float)width
{
	NPPLabel *labelView = [[self alloc] initWithCenterString:title
													   font:[UIFont nppFontBoldWithSize:pointSize]
												   maxWidth:width];
	
	return nppAutorelease(labelView);
}

+ (id) labelItalic:(NSString *)title fontSize:(float)pointSize maxWidth:(float)width
{
	NPPLabel *labelView = [[self alloc] initWithCenterString:title
														font:[UIFont nppFontItalicWithSize:pointSize]
													maxWidth:width];
	
	return nppAutorelease(labelView);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	// Custom button.
	self.font = [self.font nppFont];
	self.backgroundColor = nil;
	self.opaque = NO;
	self.baselineAdjustment = UIBaselineAdjustmentNone;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (void) defineLabelEdgeInsets:(UIEdgeInsets)value
{
	_defaultEdgeInsets = value;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) drawTextInRect:(CGRect)rect
{
	UIEdgeInsets insets = _defaultEdgeInsets;
	
	if (_edgeInsets.top != 0.0f || _edgeInsets.left != 0.0f ||
		_edgeInsets.bottom != 0.0f || _edgeInsets.right != 0.0f)
	{
		insets = _edgeInsets;
	}
	
	// Just saving a little bit of performance.
	if (insets.top != 0.0f || insets.left != 0.0f ||
		insets.bottom != 0.0f || insets.right != 0.0f)
	{
		rect = nppLabelRectWithEdges(rect, self.bounds, insets);
	}
	
	[super drawTextInRect:rect];
}

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
