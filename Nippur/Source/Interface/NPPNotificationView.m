/*
 *	NPPNotificationView.m
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

#import "NPPNotificationView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_NOTIFICATION_HEIGHT		65.0f
#define NPP_NOTIFICATION_MARGIN		5.0f
#define NPP_NOTIFICATION_TENSION	60.0f
#define NPP_NOTIFICATION_ICON		@"AppIcon29x29"

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

NPP_STATIC_READONLY(nppDefaultNotification, NPPNotificationView);

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPNotificationView()
{
@protected
	unsigned int				_displayCount;
	NPPWindow					*_displayWindow;
	
	CGPoint						_gestureStartPoint;
}

- (void) initializing;
- (void) recalculateSizes;
- (void) scheduleHideAnimated:(BOOL)animated;
- (void) moveY:(float)posY animated:(BOOL)animated completion:(NPPBlockVoid)completion;
- (void) handlePan:(UIPanGestureRecognizer *)gesture;
- (void) handleTap:(UIPanGestureRecognizer *)gesture;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

UIImage *nppNotificationMark(CGRect frame, NPPDirection direction)
{
	UIView *mask = [UIView viewWithFrame:frame];
	UIView *view = [UIView viewWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 7.0f)];
	view.layer.cornerRadius = 3.0f;
	view.backgroundColor = [UIColor blackColor];
	[mask addSubview:view];
	
	switch (direction)
	{
		case NPPDirectionUp:
			[view centerXInView:mask];
			view.y = 4.0f;
			break;
		case NPPDirectionDown:
		default:
			[view centerXInView:mask];
			view.y = mask.height - view.height - 4.0f;
			break;
	}
	
	NPPImage *snapshot = [mask snapshot];
	[snapshot makeAlphaMaskNegative:YES];
	
	//TODO not the correct resizable.
	return [snapshot imageNineSliced];
}

#pragma mark -
#pragma mark Public Class
//**************************************************
//	Public Class
//**************************************************

@implementation NPPNotificationView

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic title, message, icon;

- (NSString *) title { return _lbTitle.text; }
- (void) setTitle:(NSString *)value
{
	_lbTitle.text = value;
	[self recalculateSizes];
}

- (NSString *) message { return _lbMessage.text; }
- (void) setMessage:(NSString *)value
{
	_lbMessage.text = value;
	[self recalculateSizes];
}

- (UIImage *) icon { return _ivIcon.image; }
- (void) setIcon:(UIImage *)value
{
	_ivIcon.image = value;
}

- (NPPNotificationType) type { return _type; }
- (void) setType:(NPPNotificationType)value
{
	_type = value;
	
	UIPanGestureRecognizer *pan = nil;
	UITapGestureRecognizer *tap = nil;
	[self removeAllGestures];
	
	switch (_type)
	{
		case NPPNotificationTypeStatic:
			_ivBackground.alpha = 0.6f;
			_ivBackground.image = nil;
			_ivBackground.backgroundColor = [UIColor blackColor];
			_viBackground.frame = self.bounds;
			_lbTitle.textColor = [UIColor whiteColor];
			_lbMessage.textColor = [UIColor whiteColor];
			break;
		case NPPNotificationTypeInteractive:
		default:
			_ivBackground.alpha = 0.6f;
			_ivBackground.image = nppNotificationMark(_ivBackground.bounds, NPPDirectionDown);
			_viBackground.frame = self.bounds;
			_lbTitle.textColor = [UIColor whiteColor];
			_lbMessage.textColor = [UIColor whiteColor];
			
			pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
			[self addGestureRecognizer:pan];
			nppRelease(pan);
			
			tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
			[self addGestureRecognizer:tap];
			nppRelease(tap);
			break;
	}
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

+ (NPPNotificationView *) notificationGlobal
{
	return nppDefaultNotification();
}

+ (NPPNotificationView *) notificationWithCustomContent:(UIView *)view
{
	NPPNotificationView *notification = [[NPPNotificationView alloc] init];
	[notification setCustomContent:view];
	
	return nppAutorelease(notification);
}

+ (NPPNotificationView *) notificationWithTitle:(NSString *)title
										message:(NSString *)message
										   time:(float)seconds
{
	NPPNotificationView *notification = [[NPPNotificationView alloc] init];
	notification.title = title;
	notification.message = message;
	[notification showWithDuration:seconds animated:YES];
	
	return nppAutorelease(notification);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	// Calculating the final size.
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	CGRect screen = nppDeviceScreenRectOriented(NO);
	CGRect frame = CGRectZero;
	
	switch (orientation)
	{
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			frame.size.width = screen.size.height;
			frame.size.height = NPP_NOTIFICATION_HEIGHT;
			break;
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
		default:
			frame.size.width = screen.size.width;
			frame.size.height = NPP_NOTIFICATION_HEIGHT;
			break;
	}
	
	//TODO make all these values constants.
	// Creating the frames and icons.
	UIImage *icon = [nppImageFromFile(NPP_NOTIFICATION_ICON) NPPImage];
	CGRect labelFrame = CGRectMake(50.0f, 5.0f, frame.size.width - 80.0f, 15.0f);
	CGRect iconFrame = CGRectMake(15.0f, 10.0f, 20.0f, 20.0f);
	UIViewAutoresizing mask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	//*************************
	//	Effects
	//*************************
	
	// Holder. View pretended to be behind the background for extra effects (like blur).
	_viBackground = [[UIView alloc] init];
	_viBackground.clipsToBounds = YES;
	
	//*************************
	//	iOS Style
	//*************************
	
	_viHolder = [[UIView alloc] initWithFrame:frame];
	_viHolder.backgroundColor = [UIColor clearColor];
	_viHolder.opaque = NO;
	_viHolder.autoresizingMask = NPPAutoresizingAll;
	_viHolder.clipsToBounds = NO;
	
	// Background.
	CGRect background = frame;
	background.origin.y -= NPP_NOTIFICATION_TENSION;
	background.size.height += NPP_NOTIFICATION_TENSION;
	_ivBackground = [[UIImageView alloc] initWithFrame:background];
	_ivBackground.contentMode = UIViewContentModeScaleToFill;
	_ivBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_ivBackground.opaque = NO;
	
	// Texts.
	_lbTitle = [[UILabel alloc] initWithFrame:labelFrame];
	_lbTitle.backgroundColor = [UIColor clearColor];
	_lbTitle.font = [UIFont boldSystemFontOfSize:14.0f];
	_lbTitle.autoresizingMask = mask;
	
	labelFrame.origin.y += labelFrame.size.height;
	labelFrame.size.height = frame.size.height - labelFrame.origin.y;
	_lbMessage = [[UILabel alloc] initWithFrame:labelFrame];
	_lbMessage.backgroundColor = [UIColor clearColor];
	_lbMessage.font = [UIFont systemFontOfSize:14.0f];
	_lbMessage.autoresizingMask = mask;
	_lbMessage.numberOfLines = 2;
	
	// Icon.
	_ivIcon = [[UIImageView alloc] initWithImage:icon];
	_ivIcon.contentMode = UIViewContentModeScaleAspectFit;
	_ivIcon.autoresizingMask = mask;
	_ivIcon.frame = iconFrame;
	_ivIcon.layer.cornerRadius = 5.0f;
	_ivIcon.layer.masksToBounds = YES;
	
	frame.origin.y = -frame.size.height;
	self.frame = frame;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.type = NPPNotificationTypeInteractive;
	
	[_viHolder addSubview:_viBackground];
	[_viHolder addSubview:_ivBackground];
	[_viHolder addSubview:_lbTitle];
	[_viHolder addSubview:_lbMessage];
	[_viHolder addSubview:_ivIcon];
	[self addSubview:_viHolder];
}

- (void) recalculateSizes
{
	CGSize maxSize;
	CGSize finalSize;
	
	// Title size.
	maxSize = _lbTitle.size;
	maxSize.height = NPP_NOTIFICATION_HEIGHT;
	finalSize = [[_lbTitle text] sizeWithFont:_lbTitle.font
								  constrained:maxSize
									lineBreak:_lbTitle.lineBreakMode];
	
	_lbTitle.height = finalSize.height;
	
	// Text size.
	maxSize = _lbMessage.size;
	maxSize.height = NPP_NOTIFICATION_HEIGHT;
	finalSize = [[_lbMessage text] sizeWithFont:_lbMessage.font
									constrained:maxSize
									  lineBreak:_lbMessage.lineBreakMode];
	
	_lbMessage.height = finalSize.height;
	
	// Total height.
	self.height = MAX(NPP_NOTIFICATION_HEIGHT, _lbMessage.y + _lbMessage.height + NPP_NOTIFICATION_MARGIN);
}

- (void) scheduleHideAnimated:(BOOL)animated
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	// Schedulling the remove action. It uses a property to track the last hidding time,
	// which can be refreshed on every new interaction.
	[self performSelector:@selector(hideAnimated:)
			   withObject:[NSNumber numberWithBool:animated]
			   afterDelay:_seconds];
}

- (void) moveY:(float)posY animated:(BOOL)animated completion:(NPPBlockVoid)completion
{
	float height = self.height;
	
	if (!animated)
	{
		self.y = posY;
		[_viBackground setY:-posY];
		[_viBackground setHeight:height + posY];
		nppBlock(completion);
	}
	else
	{
		[self runAction:[NPPAction moveKey:@"y" to:posY duration:kNPPAnimTime]];
		[_viBackground runAction:[NPPAction moveKey:@"y" to:-posY duration:kNPPAnimTime]];
		[_viBackground runAction:[NPPAction moveKey:@"height" to:height + posY duration:kNPPAnimTime]
				  completion:completion];
	}
}

- (void) handlePan:(UIPanGestureRecognizer *)gesture
{
	UIGestureRecognizerState state = [gesture state];
	CGPoint point = [gesture locationInView:self.superview];
	CGPoint velocity = [gesture velocityInView:self];
	CGPoint origin = CGPointMake(self.width, self.height);
	float distance = 0.0f;
	float delta = 0.0f;
	float maxT = NPP_NOTIFICATION_TENSION;
	float posY = 0.0f;
	BOOL animated = NO;
	
	// Gets the vertical distance from touch to origin (the size).
	point.x = 0.0f;
	origin.x = 0.0f;
	distance = nppPointsDistance(origin, point);
	
	if (point.y > origin.y)
	{
		delta = MIN(distance / maxT, 1.0f);
		point.y -= (distance * delta) * 0.5f;
		point.y = MIN(origin.y + maxT, point.y);
	}
	
	posY = (point.y - origin.y);
	
	// Removing any scheduled request.
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	switch (state)
	{
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			if (velocity.y < -200.0f)
			{
				[self hideForcefullyAnimated:YES];
			}
			else
			{
				posY = 0.0f;
				animated = YES;
				[self scheduleHideAnimated:YES];
			}
			break;
		default:
			break;
	}
	
	[self moveY:posY animated:animated completion:nil];
}

- (void) handleTap:(UIPanGestureRecognizer *)gesture
{
	nppBlock(_block);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) setBlock:(NPPBlockVoid)block
{
	nppRelease(_block);
	_block = [block copy];
}

- (void) setCustomContent:(UIView *)view
{
	if (view == nil)
	{
		[self removeAllSubviews];
		[self addSubview:_viHolder];
		[_viHolder insertSubview:_viBackground atIndex:0];
		
		self.size = _viHolder.size;
	}
	else
	{
		[self removeAllSubviews];
		[self addSubview:view];
		[view insertSubview:_viBackground atIndex:0];
		
		self.size = view.size;
	}
}

- (void) showWithDuration:(float)seconds animated:(BOOL)animated
{
	[self showAnimated:animated];
	
	// Schedulling the remove action.
	_seconds = seconds;
	[self scheduleHideAnimated:animated];
}

- (void) showAnimated:(BOOL)animated
{
	// Just show once at the begining, in short:
	// If it's 0 then passes, besides increments it at every try.
	if (_displayCount == 0)
	{
		// Getting full frame.
		CGRect snapFrame = self.bounds;
		snapFrame.size.height += NPP_NOTIFICATION_TENSION;
		
		// Creating the blur effect.
		UIWindow *keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
		NPPBackdropView *backdrop = [NPPBackdropView viewWithFrame:snapFrame];
		
		backdrop.autoUpdate = NO;
		backdrop.blurredView = keyWindow;
		
		[_viBackground addSubview:backdrop];
		_viBackground.y = self.height;
		_viBackground.height = 0.0f;
		
		// Initializes the window once for the default notification.
		// Custom notifications use their own windows and superviews.
		if (self == nppDefaultNotification() || self.superview == nil)
		{
			nppRelease(_displayWindow);
			_displayWindow = [[NPPWindow alloc] initWithFrame:self.bounds];
			_displayWindow.windowLevel = UIWindowLevelStatusBar;
			_displayWindow.hidden = NO;
			[_displayWindow addSubview:self];
		}
	}
	
	// Increments the view count.
	_displayCount++;
	
	// Removes any on-going animation and start the final animation.
	[self removeAllActions];
	[self moveY:0.0f animated:animated completion:nil];
}

- (void) hideAnimated:(BOOL)animated
{
	// Just descrease if there is at least one notification view.
	if (_displayCount > 0)
	{
		// Decrements the count.
		--_displayCount;
		
		// Tries to remove the notification view only on the last hide call.
		if (_displayCount == 0)
		{
			NPPBlockVoid completion = ^(void)
			{
				if (self.superview == _displayWindow)
				{
					nppRelease(_displayWindow);
				}
				
				[self removeFromSuperview];
			};
			
			// Removes any on-going animation and start the final animation.
			[self removeAllActions];
			[self moveY:-self.height animated:animated completion:completion];
		}
	}
}

- (void) hideForcefullyAnimated:(BOOL)animated
{
	_displayCount = 1;
	[self hideAnimated:animated];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_block);
	nppRelease(_viBackground);
	
	nppRelease(_viHolder);
	nppRelease(_lbTitle);
	nppRelease(_lbMessage);
	nppRelease(_ivIcon);
	nppRelease(_ivBackground);
	
	nppRelease(_displayWindow);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
