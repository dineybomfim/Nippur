/*
 *	NPPWindow.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/2/12.
 *	Copyright 2012 db-in. All rights reserved.
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
