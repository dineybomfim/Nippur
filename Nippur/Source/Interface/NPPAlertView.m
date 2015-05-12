/*
 *	NPPAlertView.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/18/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPAlertView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_ALERT_WIDTH				320.0f
#define NPP_ALERT_LOADING_WIDTH		220.0f
#define NPP_ALERT_MARGIN			20.0f
#define NPP_ALERT_SPACE				5.0f
#define NPP_ALERT_BG				@"npp_alert_bg.png"
#define NPP_ALERT_KEY_ANIM			@"NPPKeyAlertAnim"

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
static BOOL _defaultIsNative = YES;

static float _defaultMargin = NPP_ALERT_MARGIN;
static float _defaultSpace = NPP_ALERT_SPACE;
NPP_ARC_UNSAFE static NPPAlertView *_defaultAlertView = nil;

typedef struct
{
	NPPStyleColor style;
	NPPBlockVoid block;
	NPP_ARC_UNSAFE NSString *title;
	NPP_ARC_UNSAFE NSString *image;
	NPP_ARC_UNSAFE UIView *view;
} NPPAlertItem;

static const NPPAlertItem kNPPAlertItemEmpty = (NPPAlertItem){ NPPStyleColorLight, nil, nil, nil, nil };

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NSDictionary *nppAlertDict(NPPStyleColor style, NSString *title, NSString *img, NPPBlockVoid block)
{
	NSString *empty = [NSString string];
	id copyblock = (block != nil) ? [block copy] : [[NSNull null] copy];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:style], @"style",
								(title != nil) ? title : empty, @"title",
								(img != nil) ? img : empty, @"image",
								copyblock, @"block",
								nil];
	
	nppRelease(copyblock);
	
	return dictionary;
}

static NSDictionary *nppAlertCustomView(UIView *view)
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								view, @"view",
								nil];
	
	return dictionary;
}

static NPPAlertItem nppAlertItem(NSDictionary *dict)
{
	NPPAlertItem item = kNPPAlertItemEmpty;
	UIView *customView = [dict objectForKey:@"view"];
	
	if (customView != nil)
	{
		item.view = customView;
	}
	else
	{
		item.style = [[dict objectForKey:@"style"] intValue];
		item.title = [dict objectForKey:@"title"];
		item.image = [dict objectForKey:@"image"];
		//item.block = [dict objectForKey:@"block"];
	}
	
	return item;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPAlertView() <UIAlertViewDelegate>

// Initializes a new instance.
- (void) initializing;

- (void) actionTouch:(id)sender;
- (void) executeBlockAt:(int)index;

- (void) updateNativeLayout;
- (void) updateCustomLayout;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPAlertView

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize margin = _margin, space = _space;

@dynamic title, message, backgroundImage;

- (NSString *) title { return _lbTitle.text; }
- (void) setTitle:(NSString *)value
{
	CGSize size = [value sizeWithFont:_lbTitle.font
						  constrained:CGSizeMake(_lbTitle.width, 300.0f)
							lineBreak:NSLineBreakByWordWrapping];
	
	_lbTitle.text = value;
	_lbTitle.height = size.height;
	
	_height = _lbTitle.height + _lbMessage.height + (_margin * 3.0f);
}

- (NSString *) message { return _lbMessage.text; }
- (void) setMessage:(NSString *)value
{
	CGSize size = [value sizeWithFont:_lbMessage.font
						  constrained:CGSizeMake(_lbMessage.width, 300.0f)
							lineBreak:NSLineBreakByWordWrapping];
	
	_lbMessage.text = value;
	_lbMessage.y = _lbTitle.y + _lbTitle.height + _margin;
	_lbMessage.height = size.height;
	
	_height = _lbTitle.height + _lbMessage.height + (_margin * 3.0f);
}

- (UIImage *) backgroundImage { return _ivBackground.image; }
- (void) setBackgroundImage:(UIImage *)value
{
	_ivBackground.image = [value imageNineSliced];
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

- (id) initWithTitle:(NSString *)title message:(NSString *)message
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializing];
		
		self.title = title;
		self.message = message;
	}
	
	return self;
}

+ (id) alertWithTitle:(NSString *)title message:(NSString *)message
{
	NPPAlertView *nppAlert = [[self alloc] initWithTitle:title message:message];
	
	return nppAutorelease(nppAlert);
}

+ (id) alerting:(NSString *)title message:(NSString *)message
{
	if (_defaultAlertView == nil)
	{
		_defaultAlertView = nppAutorelease([[self alloc] initWithTitle:title message:message]);
		[_defaultAlertView show];
	}
	else
	{
		[_defaultAlertView removeAllItems];
		_defaultAlertView.title = title;
		_defaultAlertView.message = message;
		[_defaultAlertView updateLayout];
	}
	
	return _defaultAlertView;
}

+ (id) alerting:(NSString *)title message:(NSString *)message done:(NSString *)done
{
	if (_defaultAlertView == nil)
	{
		_defaultAlertView = nppAutorelease([[self alloc] initWithTitle:title message:message]);
		[_defaultAlertView addButtonWithTitle:done block:nil];
		[_defaultAlertView show];
	}
	else
	{
		[_defaultAlertView removeAllItems];
		_defaultAlertView.title = title;
		_defaultAlertView.message = message;
		[_defaultAlertView addButtonWithTitle:done block:nil];
		[_defaultAlertView updateLayout];
	}
	
	return _defaultAlertView;
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
	_items = [[NSMutableArray alloc] init];
	_width = (_width > 0) ? _width : NPP_ALERT_WIDTH;
	_height = _margin;
	
	UIImage *image = nil;
	UIView *parentView = [[NPPWindowOverlay instance] view];
	CGRect frame = parentView.bounds;
	frame.origin.x = floorf((frame.size.width - _width) * 0.5f);
	frame.size.width = _width;
	
	self.frame = frame;
	self.autoresizingMask = NPPAutoresizingAllMargins;
	self.clipsToBounds = NO;
	
	//*************************
	//	View Hierarchy
	//*************************
	
	image = nppImageFromFile((_defaultBackground != nil) ? _defaultBackground : NPP_ALERT_BG);
	_ivBackground = [[UIImageView alloc] initWithImage:[image imageNineSliced]];
	_ivBackground.contentMode = UIViewContentModeScaleToFill;
	//_ivBackground.autoresizingMask = NPPAutoresizingAll;
	
	frame = CGRectMake(_margin, _height, _width - (_margin * 2.0f), 0.0f);
	_lbTitle = [[NPPLabel alloc] initWithFrame:frame];
	_lbTitle.numberOfLines = 0;
	_lbTitle.font = [UIFont nppFontBoldWithSize:20.0f];
	_lbTitle.textColor = [UIColor darkGrayColor];
	_lbTitle.textAlignment = NSTextAlignmentCenter;
	
	frame = CGRectMake(_margin, _height, _width - (_margin * 2.0f), 0.0f);
	_lbMessage = [[NPPLabel alloc] initWithFrame:frame];
	_lbMessage.numberOfLines = 0;
	_lbMessage.font = [UIFont nppFontRegularWithSize:18.0f];
	_lbMessage.textColor = [UIColor darkGrayColor];
	_lbMessage.textAlignment = NSTextAlignmentCenter;
	
	//*************************
	//	Actions / Gestures
	//*************************
}

- (void) actionTouch:(id)sender
{
	[self executeBlockAt:(unsigned int)[(UIButton *)sender tag] - 1];
}

- (void) executeBlockAt:(int)index
{
	id obj = nil;
	
	if (index >= 0 && index < [_items count])
	{
		obj = [[_items objectAtIndex:index] objectForKey:@"block"];
		
		if (![obj isEqual:[NSNull null]])
		{
			nppBlock((NPPBlockVoid)obj);
		}
	}
	
	[self dismiss];
}

#pragma mark -
#pragma mark UIAlertView Delegate
//*************************
//	UIAlertView Delegate
//*************************

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self executeBlockAt:(int)buttonIndex];
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

- (void) addButtonWithTitle:(NSString *)title
					  image:(NSString *)named
					  style:(NPPStyleColor)style
					  block:(NPPBlockVoid)block
{
	[_items addObject:nppAlertDict(style, title, named, block)];
}

- (void) addViewItem:(UIView *)item
{
	[_items addObject:nppAlertCustomView(item)];
}

- (void) show
{
	// Adjust the final size.
	NPPWindowOverlay *alertWindow = [NPPWindowOverlay instance];
	UIView *superView = [alertWindow view];
	CGSize superSize = superView.size;
	NPPAction *animation = [NPPAction moveKey:@"y" from:superSize.height duration:kNPPAnimTimeX2];
	animation.ease = NPPActionEaseBackOut;
	
	[self updateLayout];
	
	// Presenting this alert.
	[alertWindow addView:self];
	[self runAction:animation withKey:NPP_ALERT_KEY_ANIM];
	
	// Dispatching the notification object.
	[NSNotificationCenter defaultCenterPostMainNotification:kNPPNotificationAlertDidShow];
}

- (void) dismiss
{
	// Dismissing this alert.
	NPPWindowOverlay *alertWindow = [NPPWindowOverlay instance];
	NPPAction *animation = [NPPAction moveKey:@"y" to:alertWindow.view.height duration:kNPPAnimTime];
	
	[self runAction:animation withKey:NPP_ALERT_KEY_ANIM];
	[alertWindow removeView:self];
	
	if (_defaultAlertView == self)
	{
		_defaultAlertView = nil;
	}
	
	// Dispatching the notification object.
	[NSNotificationCenter defaultCenterPostMainNotification:kNPPNotificationAlertDidHide];
}

- (unsigned int) buttonsCount
{
	return (unsigned int)_items.count;
}

- (void) removeAllItems
{
	[_items removeAllObjects];
	[self removeAllSubviews];
}

- (void) updateLayout
{
	if (_defaultIsNative)
	{
		[self updateNativeLayout];
	}
	else
	{
		[self updateCustomLayout];
	}
}

- (void) updateNativeLayout
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_lbTitle.text
													message:_lbMessage.text
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:nil];
	
	NPPAlertItem item = kNPPAlertItemEmpty;
	unsigned int i = 0;
	unsigned int length = (unsigned int)[_items count];
	
	for (i = 0; i < length; i++)
	{
		item = nppAlertItem([_items objectAtIndex:i]);
		
		// Adding custom views.
		if (item.view != nil)
		{
			
		}
		else
		{
			[alert addButtonWithTitle:item.title];
		}
	}
	
	[alert show];
	nppRelease(alert);
}

- (void) updateCustomLayout
{
	BOOL isDoubleItemLine = NO;
	CGRect bounds = self.bounds;
	float halfWidth = floorf((bounds.size.width - (_margin * 2.0f) - _space) * 0.5f);
	UIFont *buttonFont = [UIFont nppFontBoldWithSize:18.0f];
	SEL action = @selector(actionTouch:);
	NPPButton *button = nil;
	float width = 0.0f;
	float posX = 0.0f;
	CGRect frame = CGRectZero;
	NPPAlertItem item = kNPPAlertItemEmpty;
	unsigned int i = 0;
	unsigned int length = (unsigned int)[_items count];
	
	[self addSubview:_ivBackground];
	[self addSubview:_lbTitle];
	[self addSubview:_lbMessage];
	
	for (i = 0; i < length; i++)
	{
		width = bounds.size.width - (_margin * 2.0f);
		posX = _margin;
		
		item = nppAlertItem([_items objectAtIndex:i]);
		
		// Adding custom views.
		if (item.view != nil)
		{
			UIView *viewItem = item.view;
			
			// Cancel any double line.
			isDoubleItemLine = NO;
			
			// Calculates the frame.
			frame = CGRectMake(posX, _height, width, viewItem.height);
			frame.origin.x += _space;
			frame.size.width -= _space * 2.0f;
			viewItem.frame = frame;
			
			[self addSubview:viewItem];
		}
		// Adding buttons.
		else
		{
			// Prepares the default frame.
			NSString *title = item.title;
			NSString *image = item.image;
			
			// Creating the button on the right.
			if (isDoubleItemLine)
			{
				width = halfWidth;
				posX = _margin + width + _space;
				isDoubleItemLine = NO;
			}
			// Verifies and creates a line with two buttons, if it's applicable.
			else if (i + 1 < _items.count)
			{
				// Checks if the current button fit on the half size.
				CGSize size = [title sizeWithFont:buttonFont
										  minSize:10
										 forWidth:width
										lineBreak:0];
				
				if (size.width < halfWidth)
				{
					// Checks now if the next button will fit in the same line.
					NPPAlertItem item2 = nppAlertItem([_items objectAtIndex:i + 1]);
					NSString *title2 = item2.title;
					size = [title2 sizeWithFont:buttonFont
										minSize:10
									   forWidth:width
									  lineBreak:0];
					
					if (size.width < halfWidth && item2.view == nil)
					{
						// Both will fit.
						// Adjust the current width and sets the flag to instruct the next one.
						width = halfWidth;
						isDoubleItemLine = YES;
					}
				}
			}
			
			button = [NPPButton buttonWithTitle:title image:nil type:NPPButtonTypeBase style:item.style];
			[button setImage:nppImageFromFile(image) forState:UIControlStateNormal];
			[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
			button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, NPP_ALERT_SPACE, 0.0f, NPP_ALERT_SPACE);
			button.tag = i + 1;
			
			frame = CGRectMake(posX, _height, width, MAX(button.height, 44.0f));
			button.frame = frame;
			
			[self addSubview:button];
		}
		
		if (!isDoubleItemLine)
		{
			_height += frame.size.height + _space;
		}
	}
	
	// Bottom margin.
	_height += _space * 2.0f;
	
	// Adjust the final size.
	NPPWindowOverlay *alertWindow = [NPPWindowOverlay instance];
	UIView *superView = [alertWindow view];
	CGSize superSize = superView.size;
	
	self.width = MIN(superSize.width, _width);
	self.height = MIN(superSize.height, _height);
	self.contentSize = CGSizeMake(_width, _height);
	self.showsVerticalScrollIndicator = NO;
	[self centerInView:superView];
	
	_ivBackground.frame = CGRectMake(0.0f, 0.0f, _width, _height);
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

+ (void) defineNativeAlerts:(BOOL)isNative
{
	_defaultIsNative = isNative;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_items);
	nppRelease(_lbTitle);
	nppRelease(_lbMessage);
	nppRelease(_ivBackground);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
