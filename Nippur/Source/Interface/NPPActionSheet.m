/*
 *	NPPActionSheet.m
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

#import "NPPActionSheet.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_SHEET_MARGIN			10.0f
#define NPP_SHEET_SPACE				0.0f
#define NPP_SHEET_MAX_HEIGHT		380.0f
#define NPP_SHEET_ICONS_LINE		3
#define NPP_SHEET_BG				@"npp_action_sheet.png"

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

NPP_ARC_RETAIN static NSString *_defaultBackground = nil;
static float _defaultMargin = NPP_SHEET_MARGIN;
static float _defaultSpace = NPP_SHEET_SPACE;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPActionSheet()

// Initializes a new instance.
- (void) initializing;

- (void) actionTouch:(id)sender;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPActionSheet

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize margin = _margin, space = _space, style = _style, iconsPerLine = _iconsPerLine,
			backgroundImage = _backgroundImage;

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

- (id) initWithTitle:(NSString *)title
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializing];
		
		float textWidth = self.width - (_margin * 2.0f);
		
		if (title)
		{
			NPPLabel *labelView = [NPPLabel labelBold:title fontSize:18.0f maxWidth:textWidth];
			labelView.x = _margin;
			labelView.y = _height;
			_height += labelView.height + _space;
			
			[self addSubview:labelView];
		}
	}
	
	return self;
}

+ (id) sheetWithTitle:(NSString *)title
{
	NPPActionSheet *nppAlert = [[self alloc] initWithTitle:title];
	
	return nppAutorelease(nppAlert);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	_margin = _defaultMargin;
	_space = _defaultSpace;
	_blocks = [[NSMutableArray alloc] init];
	_height = 0.0f;//_margin * 2.0f;
	_iconsPerLine = NPP_SHEET_ICONS_LINE;
	
	CGRect bounds = nppDeviceScreenRectOriented(NO);
	UIView *parentView = [[NPPWindowOverlay instance] view];
	CGRect frame = parentView.bounds;
	frame.origin.x = floorf((frame.size.width - bounds.size.width) * 0.5f);
	frame.size.width = bounds.size.width;
	
	self.frame = frame;
	
	// Taking the resizable asset. It's halved of the top middle.
	UIImage *image = nppImageFromFile((_defaultBackground != nil) ? _defaultBackground : NPP_SHEET_BG);
	CGSize size = image.size;
	int halfW = (int)(size.width + 1) >> 1;
	int halfH = (int)(size.height + 1) >> 1;
	float halfHMiddle = (halfH * 0.5f);
	UIEdgeInsets edge = UIEdgeInsetsMake(halfHMiddle - 1, halfW - 1, halfH + halfHMiddle + 1, halfW + 1);
	
	self.backgroundImage = [image resizableImageWithCapInsets:edge];
}

- (void) actionTouch:(id)sender
{
	// Handles the touch.
	int buttonIndex = (int)[(UIButton *)sender tag] - 1;
	if (buttonIndex >= 0 && buttonIndex < [_blocks count])
	{
		id obj = [[_blocks objectAtIndex: buttonIndex] objectForKey:@"block"];
		if (![obj isEqual:[NSNull null]])
		{
			nppBlock((NPPBlockVoid)obj);
		}
	}
	
	[self dismiss];
}

- (void) addButtonWithTitle:(NSString *)title
					  image:(NSString *)named
					  style:(NPPStyleColor)style
					  block:(NPPBlockVoid)block
{
	NSString *empty = [NSString string];
	id copyblock = [block copy];
	copyblock = (copyblock != nil) ? copyblock : [[NSNull null] copy];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:style], @"style",
								(title != nil) ? title : empty, @"title",
								(named != nil) ? named : empty, @"image",
								copyblock, @"block",
								nil];
	
	[_blocks addObject:dictionary];
	
	nppRelease(copyblock);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block
{
	[self addButtonWithTitle:title image:nil style:NPPStyleColorLight block:block];
}

- (void) addConfirmButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block
{
	[self addButtonWithTitle:title image:nil style:NPPStyleColorConfirm block:block];
}

- (void) addCancelButtonWithTitle:(NSString *)title block:(NPPBlockVoid)block
{
	[self addButtonWithTitle:title image:nil style:NPPStyleColorAlert block:block];
}

- (void) show
{
	CGRect bounds = self.bounds;
	SEL action = @selector(actionTouch:);
	NSDictionary *item = nil;
	NSString *title = nil;
	NSString *image = nil;
	NPPButton *button = nil;
	NPPStyleColor style;
	BOOL isLastButton;
	
	// Scroll View.
	CGRect frame = CGRectZero;
	CGRect contentFrame = CGRectMake(0.0f, 0.0f, bounds.size.width, 0.0f);
	CGRect scrollFrame = CGRectMake(0.0f, _height, bounds.size.width, 0.0f);
	UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.pagingEnabled = (_style == NPPActionSheetStyleIcons);
	[self addSubview:scrollView];
	
	// Specific to styles.
	unsigned int pageIndex = 0;
	float lineHeight = 0.0f;
	float width = bounds.size.width - (_margin * 2.0f);
	
	unsigned int i = 0;
	unsigned int length = (unsigned int)[_blocks count];
	
	for (i = 0; i < length; ++i)
	{
		item = [_blocks objectAtIndex:i];
		style = [[item objectForKey:@"style"] intValue];
		title = [item objectForKey:@"title"];
		image = [item objectForKey:@"image"];
		
		isLastButton = (i + 1 == length);
		
		// Action sheet with list.
		if (_style == NPPActionSheetStyleDefault || _style == NPPActionSheetStyleList || isLastButton)
		{
			//TODO DO IT RIGHT!!!!!
//			button = [NPPButton buttonWithTitle:title image:nil type:NPPButtonTypeBase style:style];
			button = [[NPPButton alloc] init];
			[button setTitle:title forState:UIControlStateNormal];
			[[button titleLabel] setFont:[UIFont nppFontRegularWithSize:16.0f]];
			[button setTitleColor:[UIColor colorWithHexadecimalRGB:0x444444] forState:UIControlStateNormal];
			[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
			[button setImage:nppImageFromFile(image) forState:UIControlStateNormal];
//			[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//			[button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 0.0f)];
			[button setTarget:self action:action];
			button.height = 60.0f;
			button.tag = i + 1;
			
			frame = CGRectMake(_margin, contentFrame.origin.y, width, MAX(button.height, 44.0f));
			button.frame = frame;
			
			// The last button doesn't enter in the scroll view and it has the double space.
			if (isLastButton)
			{
				[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
				button.y = _height + scrollFrame.size.height;
				_height += frame.size.height;
				[self addSubview:button];
			}
			else
			{
				contentFrame.origin.y += frame.size.height + _space;
				contentFrame.size.height = contentFrame.origin.y;
				scrollFrame.size.height = MIN(contentFrame.size.height, NPP_SHEET_MAX_HEIGHT);
				[scrollView addSubview:button];
			}
			
			nppRelease(button);
		}
		// Action sheet with icons only.
		else if (_style == NPPActionSheetStyleIcons)
		{
			contentFrame.origin.x += _margin * 2.0f;
			
			button = [NPPButton buttonWithTitle:title image:image type:NPPButtonTypeBase style:style];
			[button setTarget:self action:action];
			button.x = contentFrame.origin.x + (bounds.size.width * pageIndex);
			button.y = contentFrame.origin.y;
			button.tag = i + 1;
			
			[scrollView addSubview:button];
			
			// Sets the maximum content height and the minimum scroll height.
			lineHeight = MAX(lineHeight, button.height + _space);
			contentFrame.size.height = MAX(contentFrame.size.height, contentFrame.origin.y + lineHeight);
			scrollFrame.size.height = MIN(contentFrame.size.height, NPP_SHEET_MAX_HEIGHT);
			
			// Checks if there is a line break.
			contentFrame.origin.x += button.width;
			if (contentFrame.origin.x + (_margin * 2.0f) >= width)
			{
				// Setting the new line and checking if there is a page break.
				contentFrame.origin.x = 0.0f;
				contentFrame.origin.y += lineHeight;
				if (contentFrame.origin.y >= NPP_SHEET_MAX_HEIGHT)
				{
					contentFrame.origin.y = 0.0f;
					++pageIndex;
					
					//TODO put UIPageControl in horizontal pages.
				}
				
				lineHeight = 0.0f;
			}
		}
	}
	
	// Adjust the final size.
	contentFrame.size.width = (bounds.size.width * ++pageIndex);
	_height += scrollFrame.size.height;
	scrollView.frame = scrollFrame;
	scrollView.contentSize = contentFrame.size;
	nppRelease(scrollView);
	self.height = _height;
	
	// Can change background per show.
	UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:self.bounds];
	modalBackground.image = _backgroundImage;
	modalBackground.contentMode = UIViewContentModeScaleToFill;
	[self insertSubview:modalBackground atIndex:0];
	nppRelease(modalBackground);
	
	NPPWindowOverlay *blockBg = [NPPWindowOverlay instance];
	[blockBg addView:self];
	
	float posY = blockBg.view.height;
	[self runAction:[NPPAction moveKey:@"y" from:posY to:posY - self.height duration:kNPPAnimTime]];
	
	// Dispatching the notification object.
	[NSNotificationCenter defaultCenterPostMainNotification:kNPPNotificationAlertDidShow];
}

- (void) dismiss
{
	NPPWindowOverlay *blockBg = [NPPWindowOverlay instance];
	
	[self moveProperty:@"y" to:blockBg.view.height completion:nil];
	[[NPPWindowOverlay instance] removeView:self];
	
	// Dispatching the notification object.
	[NSNotificationCenter defaultCenterPostMainNotification:kNPPNotificationAlertDidShow];
}

- (unsigned int) buttonsCount
{
	return (unsigned int)_blocks.count;
}

+ (void) defineMargin:(float)margin andSpace:(float)space
{
	_defaultMargin = margin;
	_defaultSpace = space;
}

+ (void) defineBackgroundImageNamed:(NSString *)named
{
	nppRelease(_defaultBackground);
	_defaultBackground = nppRetain(named);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_backgroundImage);
	nppRelease(_blocks);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
