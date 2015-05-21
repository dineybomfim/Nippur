/*
 *	NPPWindow.m
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

#import "NPPWindow.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

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

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPWindow

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic avoidKeyWindow;

- (BOOL) avoidKeyWindow { return _avoidKeyWindow; }
- (void) setAvoidKeyWindow:(BOOL)value
{
	BOOL userInteraction = self.userInteractionEnabled;
	_avoidKeyWindow = value;
	
	//*
	if (!value && userInteraction)
	{
		[super setUserInteractionEnabled:NO];
	}
	/*/
	[super setUserInteractionEnabled:!value];
	//*/
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

//- (void) showAnimated:(BOOL)animated
//{
//	if (!self.hidden)
//	{
//		return;
//	}
//	
//	// Retains the current key window.
//	//self.lastWindow = [[UIApplication sharedApplication] keyWindow];
//	
//	// Enables the current window.
//	self.hidden = NO;
//	self.userInteractionEnabled = YES;
//	[self makeKeyWindow];
//	
////	if (animated)
////	{
////		self.alpha = 0.0f;
////		[self moveProperty:@"alpha" to:1.0f completion:nil];
////	}
////	else
//	{
//		//self.alpha = 1.0f;
//	}
//}
//
//- (void) hideAnimated:(BOOL)animated
//{
//	if (self.hidden)
//	{
//		return;
//	}
//	
//	__block id bself = self;
//	
//	// The completion block.
//	NPPBlockVoid block = ^(void)
//	{
//		[bself setHidden:YES];
//		[bself setUserInteractionEnabled:NO];
//		//[_lastWindow makeKeyWindow];
//		//[bself setLastWindow:nil];
//	};
//	
//	// Making the final animation.
////	if (animated)
////	{
////		self.alpha = 1.0f;
////		[self moveProperty:@"alpha" to:0.0f completion:block];
////	}
////	else
//	{
//		//self.alpha = 0.0f;
//		nppBlock(block);
//	}
//}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) makeKeyWindow
{
	if (!_avoidKeyWindow)
	{
		[super makeKeyWindow];
	}
}

//- (BOOL) isUserInteractionEnabled { return (!_avoidKeyWindow) ? [super isUserInteractionEnabled] : NO; }
//- (void) setUserInteractionEnabled:(BOOL)value
//{
//	[super setUserInteractionEnabled:(!_avoidKeyWindow) ? value : NO];
//}

//- (void) sendEvent:(UIEvent *)event
//{
//	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//	NSSet *touches = [event allTouches];
//	UITouch *touch = nil;
//	UITouchPhase phase;
//	for (touch in touches)
//	{
//		phase = touch.phase;
//	}
//	
//	switch (phase)
//	{
//		case UITouchPhaseBegan:
//			[keyWindow touchesBegan:touches withEvent:event];
//			break;
//		case UITouchPhaseMoved:
//			[keyWindow touchesMoved:touches withEvent:event];
//			break;
//		case UITouchPhaseEnded:
//			[keyWindow touchesEnded:touches withEvent:event];
//			break;
//		default:
//			break;
//	}
//	
//	nppLog(@"..... %@",[event allTouches]);
//	[[UIApplication sharedApplication] sendEvent:event];
//}

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
