/*
 *	NPPButton.m
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

#import "NPPButton.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_BT_STATE_UP			@"up"
#define NPP_BT_STATE_DOWN		@"down"

#define NPP_BT_BASE				@"npp_bt.png"
#define NPP_BT_KEY				@"npp_bt_key.png"
#define NPP_BT_KEY_SEG			@"npp_bt_key_seg.png"

#define NPP_BT_DEFAULT_BASE		@"base"
#define NPP_BT_DEFAULT_KEY		@"keyboard"
#define NPP_BT_DEFAULT_KEY_SEG	@"keyboard_segment"
#define NPP_BT_DEFAULT_LIGHT	@"light"
#define NPP_BT_DEFAULT_DARK		@"dark"
#define NPP_BT_DEFAULT_ALERT	@"alert"
#define NPP_BT_DEFAULT_CONFIRM	@"confirm"

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

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(NSMutableDictionary, nppButtonDefaults);

static UIColor *nppUIColorConstrasting(NPPStyleColor style)
{
	UIColor *color = nil;
	
	switch (style)
	{
		case NPPStyleColorAlert:
			color = [UIColor whiteColor];
			break;
		case NPPStyleColorConfirm:
			color = [UIColor whiteColor];
			break;
		case NPPStyleColorDark:
			color = [UIColor whiteColor];
			break;
		case NPPStyleColorLight:
		default:
			color = [UIColor blackColor];
			break;
	}
	
	return color;
}

static UIImage *nppUIImageFor(NPPButtonType type, NPPStyleColor style, BOOL isUp)
{
	NSString *path = nil;
	NSString *named = nil;
	NSString *pureName = nil;
	NSString *extension = nil;
	NSString *stateName = (isUp) ? NPP_BT_STATE_UP : NPP_BT_STATE_DOWN;
	NSMutableDictionary *defaults = nppButtonDefaults();
	NSString *keyStyle = nil;
	
	switch (style)
	{
		case NPPStyleColorAlert:
			keyStyle = NPP_BT_DEFAULT_ALERT;
			break;
		case NPPStyleColorConfirm:
			keyStyle = NPP_BT_DEFAULT_CONFIRM;
			break;
		case NPPStyleColorDark:
			keyStyle = NPP_BT_DEFAULT_DARK;
			break;
		case NPPStyleColorLight:
		default:
			keyStyle = NPP_BT_DEFAULT_LIGHT;
			break;
	}
	
	switch (type)
	{
		case NPPButtonTypeKeyLeft:
		case NPPButtonTypeKeyRight:
		case NPPButtonTypeKeyMiddle:
			named = [[defaults objectForKey:NPP_BT_DEFAULT_KEY_SEG] objectForKey:keyStyle];
			break;
		case NPPButtonTypeKey:
			named = [[defaults objectForKey:NPP_BT_DEFAULT_KEY] objectForKey:keyStyle];
			break;
		case NPPButtonTypeBase:
		default:
			named = [[defaults objectForKey:NPP_BT_DEFAULT_BASE] objectForKey:keyStyle];
			break;
	}
	
	extension = nppGetFileExtension(named);
	pureName = nppGetFileName(named);
	
	// Tries the state name match only.
	path = [NSString stringWithFormat:@"%@_%@.%@", pureName, stateName, extension];
	if (!nppFileExists(path))
	{
		path = named;
	}
	
	return nppImageFromFile(path);
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPButton()

// Initializes a new instance.
- (void) initializingButton;

- (void) handleCallback:(id)sender;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPButton

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize type = _type, styleColor = _styleColor;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializingButton];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializingButton];
		
		// Loading original image.
		UIImage *up = [self backgroundImageForState:UIControlStateNormal];
		UIImage *down = [self backgroundImageForState:UIControlStateHighlighted];
		UIImage *selected = [self backgroundImageForState:UIControlStateSelected];
		
		// Gets the 9-slice image area.
		selected = (selected != up) ? [selected imageNineSliced] : nil;
		down = (down != up) ? [down imageNineSliced] : nil;
		up = [up imageNineSliced];
		
		// Make localizable text.
		BOOL hasAtt = [self respondsToSelector:@selector(attributedTitleForState:)];
		NSAttributedString *att = (hasAtt) ? [self attributedTitleForState:UIControlStateNormal] : nil;
		
		if (att != nil)
		{
			NSRange range = NSMakeRange(0, att.string.length);
			UIFont *font = [self.titleLabel.font nppFont];
			
			NSMutableAttributedString *finalString = [att mutableCopy];
			[finalString addAttribute:NSFontAttributeName value:font range:range];
			[finalString replaceCharactersInRange:range withString:nppS(self.titleLabel.text)];
			[self setAttributedTitle:finalString forState:UIControlStateNormal];
			nppRelease(finalString);
		}
		else
		{
			[self setTitle:nppS(self.titleLabel.text) forState:UIControlStateNormal];
		}
		
		[self setBackgroundImage:up forState:UIControlStateNormal];
		[self setBackgroundImage:down forState:UIControlStateHighlighted];
		[self setBackgroundImage:selected forState:UIControlStateSelected];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializingButton];
	}
	
	return self;
}

- (id) initWithTitle:(NSString *)title
			   image:(NSString *)named
				type:(NPPButtonType)type
			   style:(NPPStyleColor)style;
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializingButton];
		[self setType:type andStyle:style];
		
		UIImage *image = nppImageFromFile(named);
		self.titleLabel.font = [UIFont nppFontBoldWithSize:16.0f];
		[self setTitle:title forState:UIControlStateNormal];
		[self setImage:image forState:UIControlStateNormal];
		[self sizeToFit];
	}
	
	return self;
}

+ (id) buttonWithTitle:(NSString *)title
				  image:(NSString *)named
				  type:(NPPButtonType)type
				 style:(NPPStyleColor)style
{
	NPPButton *button = [[self alloc] initWithTitle:title image:named type:type style:style];
	return nppAutorelease(button);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializingButton
{
	// Custom button.
	UILabel *label = self.titleLabel;
	label.font = [label.font nppFont];
	_type = NPPButtonTypeBase;
	_styleColor = NPPStyleColorLight;
}

- (void) handleCallback:(id)sender
{
	nppBlock(_block);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) setTarget:(id)aTarget action:(SEL)aSelector
{
	[self removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
	[self addTarget:aTarget action:aSelector forControlEvents:UIControlEventTouchUpInside];
}

- (void) setBlock:(NPPBlockVoid)block
{
	nppRelease(_block);
	_block = [block copy];
	
	[self setTarget:self action:@selector(handleCallback:)];
}

- (void) setType:(NPPButtonType)type andStyle:(NPPStyleColor)style
{
	_type = type;
	_styleColor = style;
	
	// Loading original image.
	UIImage *up = nppUIImageFor(_type, _styleColor, YES);
	UIImage *down = nppUIImageFor(_type, _styleColor, NO);
	CGRect crop = CGRectZero;
	
	switch (_type)
	{
		case NPPButtonTypeKeyLeft:
			crop = CGRectMake(0, 0, up.size.width * 0.5f, up.size.height);
			up = [up imageCroppedInRect:crop];
			down = [down imageCroppedInRect:crop];
			self.contentMode = UIViewContentModeTopLeft;
			break;
		case NPPButtonTypeKeyRight:
			crop = CGRectMake(up.size.width * 0.5f, 0, up.size.width * 0.5f, up.size.height);
			up = [up imageCroppedInRect:crop];
			down = [down imageCroppedInRect:crop];
			self.contentMode = UIViewContentModeTopRight;
			break;
		case NPPButtonTypeKeyMiddle:
			self.contentMode = UIViewContentModeCenter;
			break;
		case NPPButtonTypeBase:
			self.contentMode = UIViewContentModeTopRight;
			break;
		case NPPButtonTypeKey:
		default:
			self.contentMode = UIViewContentModeCenter;
			break;
	}
	
	// Gets the 9-slice image area.
	up = [up imageNineSliced];
	down = [down imageNineSliced];
	
	// Creates the required button.
	[self setBackgroundImage:down forState:UIControlStateHighlighted];
	[self setBackgroundImage:down forState:UIControlStateSelected];
	[self setBackgroundImage:up forState:UIControlStateNormal];
	[self setTitleColor:nppUIColorConstrasting(_styleColor) forState:UIControlStateNormal];
}

+ (void) defineBackground:(NSString *)imageNamed type:(NPPButtonType)type style:(NPPStyleColor)style
{
	NSMutableDictionary *defaults = nppButtonDefaults();
	NSMutableDictionary *item = nil;
	NSString *keyStyle = nil;
	NSString *keyType = nil;
	
	switch (style)
	{
		case NPPStyleColorAlert:
			keyStyle = NPP_BT_DEFAULT_ALERT;
			break;
		case NPPStyleColorConfirm:
			keyStyle = NPP_BT_DEFAULT_CONFIRM;
			break;
		case NPPStyleColorDark:
			keyStyle = NPP_BT_DEFAULT_DARK;
			break;
		case NPPStyleColorLight:
		default:
			keyStyle = NPP_BT_DEFAULT_LIGHT;
			break;
	}
	
	switch (type)
	{
		case NPPButtonTypeKeyLeft:
		case NPPButtonTypeKeyRight:
		case NPPButtonTypeKeyMiddle:
			keyType = NPP_BT_DEFAULT_KEY_SEG;
			break;
		case NPPButtonTypeKey:
			keyType = NPP_BT_DEFAULT_KEY;
			break;
		case NPPButtonTypeBase:
		default:
			keyType = NPP_BT_DEFAULT_BASE;
			break;
	}
	
	if (imageNamed != nil)
	{
		item = [defaults objectForKey:keyType];
		
		if (item == nil)
		{
			item = [NSMutableDictionary dictionary];
			[defaults setObject:item forKey:keyType];
		}
		
		[item setObject:imageNamed forKey:keyStyle];
	}
	else
	{
		item = [defaults objectForKey:keyType];
		[item removeObjectForKey:keyStyle];
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_block);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

+ (void) initialize
{
	if (self == [NPPButton class])
	{
		NSString *extension = nil;
		NSString *named = nil;
		NSString *path = nil;
		
		// Base Button.
		extension = nppGetFileExtension(NPP_BT_BASE);
		named = nppGetFileName(NPP_BT_BASE);
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_LIGHT, extension];
		[self defineBackground:path type:NPPButtonTypeBase style:NPPStyleColorLight];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_DARK, extension];
		[self defineBackground:path type:NPPButtonTypeBase style:NPPStyleColorDark];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_CONFIRM, extension];
		[self defineBackground:path type:NPPButtonTypeBase style:NPPStyleColorConfirm];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_ALERT, extension];
		[self defineBackground:path type:NPPButtonTypeBase style:NPPStyleColorAlert];
		
		// Keyboard Button.
		extension = nppGetFileExtension(NPP_BT_KEY);
		named = nppGetFileName(NPP_BT_KEY);
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_LIGHT, extension];
		[self defineBackground:path type:NPPButtonTypeKey style:NPPStyleColorLight];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_DARK, extension];
		[self defineBackground:path type:NPPButtonTypeKey style:NPPStyleColorDark];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_CONFIRM, extension];
		[self defineBackground:path type:NPPButtonTypeKey style:NPPStyleColorConfirm];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_ALERT, extension];
		[self defineBackground:path type:NPPButtonTypeKey style:NPPStyleColorAlert];
		
		// Keyboard Segment Button.
		extension = nppGetFileExtension(NPP_BT_KEY_SEG);
		named = nppGetFileName(NPP_BT_KEY_SEG);
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_LIGHT, extension];
		[self defineBackground:path type:NPPButtonTypeKeyMiddle style:NPPStyleColorLight];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_DARK, extension];
		[self defineBackground:path type:NPPButtonTypeKeyMiddle style:NPPStyleColorDark];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_CONFIRM, extension];
		[self defineBackground:path type:NPPButtonTypeKeyMiddle style:NPPStyleColorConfirm];
		
		path = [NSString stringWithFormat:@"%@_%@.%@", named, NPP_BT_DEFAULT_ALERT, extension];
		[self defineBackground:path type:NPPButtonTypeKeyMiddle style:NPPStyleColorAlert];
	}
}

@end
