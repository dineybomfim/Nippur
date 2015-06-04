/*
 *	NPPWindowKeyboard.m
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

#import "NPPWindowKeyboard.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Keyboard constants.
#define NPP_KEYBOARD_PHONE_PORT		216.0f
#define NPP_KEYBOARD_PHONE_LAND		162.0f
#define NPP_KEYBOARD_PAD_PORT		264.0f
#define NPP_KEYBOARD_PAD_LAND		352.0f

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

static float nppKeyboardHeight(UIInterfaceOrientation orientation)
{
	BOOL isPad = nppDeviceIsPad();
	float height;
	
	switch (orientation)
	{
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			height = (isPad) ? NPP_KEYBOARD_PAD_LAND : NPP_KEYBOARD_PHONE_LAND;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
		case UIInterfaceOrientationPortrait:
		default:
			height = (isPad) ? NPP_KEYBOARD_PAD_PORT : NPP_KEYBOARD_PHONE_PORT;
			break;
	}
	
	return height;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPWindowKeyboard()

// Initializes a new instance.
- (void) initializing;

- (void) adjustFrameTo:(UIInterfaceOrientation)orientation;
- (void) statusbarWillChange:(NSNotification *)notification;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPWindowKeyboard

NPP_SINGLETON_IMPLEMENTATION(NPPWindowKeyboard);

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic autoAdjustToKeyboard, heightWindow, heightExtra, frameFull;

- (BOOL) autoAdjustToKeyboard { return _autoAdjustToKeyboard; }
- (void) setAutoAdjustToKeyboard:(BOOL)value
{
	_autoAdjustToKeyboard = value;
	[self adjustFrameTo:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (float) heightWindow
{
	[self adjustFrameTo:[[UIApplication sharedApplication] statusBarOrientation]];
	return _validFrame.size.height;
}
- (void) setHeightWindow:(float)value
{
	_validFrame.size.height = value;
	_autoAdjustToKeyboard = NO;
	[self adjustFrameTo:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (float) heightExtra { return _heightExtra; }
- (void) setHeightExtra:(float)value
{
	_heightExtra = value;
	[self adjustFrameTo:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (CGRect) frameFull
{
	CGRect frame = _validFrame;
	frame.size.height += _heightExtra;
	
	return frame;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithNibName:nil bundle:nil]))
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

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self initializing];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	_validFrame = nppDeviceScreenRectOriented(YES);
	_validFrame.origin = CGPointZero;
	_validFrame.size.height = nppKeyboardHeight(orientation);
	_heightExtra = 0.0f;
	_autoAdjustToKeyboard = YES;
	
	_holderView = [[UIView alloc] init];
	[[self view] addSubview:_holderView];
}

- (void) adjustFrameTo:(UIInterfaceOrientation)orientation
{
	// Adjusting the current size to the keyboard size.
	if (_autoAdjustToKeyboard)
	{
		_validFrame.size.height = nppKeyboardHeight(orientation);
	}
	
	CGRect screen = nppDeviceScreenRectOriented(YES);
	CGRect frame = CGRectZero;
	float holderHeight = _validFrame.size.height + _heightExtra;
	CGAffineTransform transform;
	UIView *selfView = self.view;
	
	// Finds the final window's frame and the view's rotation.
	switch (orientation)
	{
		case UIInterfaceOrientationPortraitUpsideDown:
			_validFrame.size.width = screen.size.width;
			transform = CGAffineTransformMakeRotation(nppDegreesToRadians(180));
			frame = CGRectMake(0.0f, 0.0f, screen.size.width, holderHeight);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			_validFrame.size.width = screen.size.height;
			transform = CGAffineTransformMakeRotation(-nppDegreesToRadians(90));
			frame = CGRectMake(screen.size.width - holderHeight, 0.0f, holderHeight, screen.size.height);
			break;
		case UIInterfaceOrientationLandscapeRight:
			_validFrame.size.width = screen.size.height;
			transform = CGAffineTransformMakeRotation(nppDegreesToRadians(90));
			frame = CGRectMake(0.0f, 0.0f, holderHeight, screen.size.height);
			break;
		case UIInterfaceOrientationPortrait:
		default:
			_validFrame.size.width = screen.size.width;
			transform = CGAffineTransformMakeRotation(nppDegreesToRadians(0));
			frame = CGRectMake(0.0f, screen.size.height - holderHeight, screen.size.width, holderHeight);
			break;
	}
	
	// First changes the window's frame.
	_window.frame = frame;
	
	// Adjust the view to fit exactly inside the window.
	selfView.transform = transform;
	selfView.size = _window.size;
	[selfView centerInView:_window];
	
	_holderView.frame = self.frameFull;
}

- (void) statusbarWillChange:(NSNotification *)notification
{
	UIInterfaceOrientation orientation;
	NSDictionary *userInfo = [notification userInfo];
	[[userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] getValue:&orientation];
	
	[self adjustFrameTo:orientation];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addView:(UIView *)view
{
	[_holderView addSubview:view];
}

- (void) addView:(UIView *)view atIndex:(int)index
{
	[_holderView insertSubview:view atIndex:index];
}

- (void) removeView:(UIView *)view
{
	NSArray *subviews = [_holderView subviews];
	
	if ([subviews indexOfObject:view] != NSNotFound)
	{
		[view removeFromSuperview];
	}
}

- (void) removeViewAtIndex:(int)index
{
	NSArray *subviews = [_holderView subviews];
	
	if (index < [subviews count])
	{
		[[subviews objectAtIndex:index] removeFromSuperview];
	}
}

- (unsigned int) viewsCount
{
	return (unsigned int)[[_holderView subviews] count];
}

- (void) showAnimated:(BOOL)animated completion:(NPPBlockVoid)block
{
	CGRect frame = _validFrame;
	frame.size.height += _heightExtra;
	
	//TODO find a better way to deal with window keyboard.
	nppRelease(_window);
	_window = [[NPPWindow alloc] initWithFrame:frame];
	_window.avoidKeyWindow = YES;
	_window.rootViewController = self;
	_window.hidden = NO;
	//[_window addSubview:self.view];
	//[_window showAnimated:NO];
	//_window.backgroundColor = [UIColor redColor];
	//self.view.backgroundColor = [UIColor blueColor];
	
	// Sets the frame for window and view.
	[self adjustFrameTo:[[UIApplication sharedApplication] statusBarOrientation]];
	
	// Changes on status bar orientation (usually) means a rotation in the key view/window.
	// So the keyboard will follow it.
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self
			   selector:@selector(statusbarWillChange:)
				   name:UIApplicationWillChangeStatusBarOrientationNotification
				 object:nil];
	
	// Sets the final position.
	if (animated)
	{
		//TODO adjust the animation to all orientations.
		//[self.view moveProperty:@"y" from:_window.height completion:block];
		nppBlock(block);
	}
	else
	{
		nppBlock(block);
	}
}

- (void) hideAnimated:(BOOL)animated completion:(NPPBlockVoid)block
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	
	// Final block, called to clear the window.
	NPPBlockVoid finalBlock = ^(void)
	{
		nppRelease(_window);
		nppBlock(block);
	};
	
	// Sets the final position.
	if (animated)
	{
		//TODO adjust the animation to all orientations.
		//[self.view moveProperty:@"y" to:_window.height completion:finalBlock];
		nppBlock(finalBlock);
	}
	else
	{
		nppBlock(finalBlock);
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (BOOL) shouldAutorotate
{
	return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return NO;
}

- (void) dealloc
{
	[self hideAnimated:NO completion:nil];
	nppRelease(_holderView);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
