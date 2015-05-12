/*
 *	NPPClockController.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 8/8/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPClockController.h"

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

#pragma mark -
#pragma mark Public Class
//**************************************************
//	Public Class
//**************************************************

@implementation NPPClockController

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize delegate = _delegate;

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

#pragma mark -
#pragma mark NPPTimerItem
//*************************
//	NPPTimerItem
//*************************

- (void) timerCallBack
{
	NSTimeInterval time = nppApplicationTime() - _startTime;
	float percentage = (_totalTime > 0.0f) ? time / _totalTime : 1.0f;
	_percentage = NPPClamp(percentage, 0.0f, 1.0f);
	
	if (time >= _totalTime)
	{
		[self stop];
	}
	
	[_delegate clockDidUpdate:self];
}

#pragma mark -
#pragma mark NPPClocking
//*************************
//	NPPClocking
//*************************

- (BOOL) reverse { return _reverse; }
- (void) setReverse:(BOOL)value
{
	_reverse = value;
}

- (NSTimeInterval) totalTime { return _totalTime; }
- (void) setTotalTime:(NSTimeInterval)value
{
	_totalTime = MAX(value, 0.0f);
	[self timerCallBack];
}

- (NSTimeInterval) currentTime { return _totalTime * self.currentPercentage; }
- (void) setCurrentTime:(NSTimeInterval)value
{
	self.currentPercentage = (_totalTime > 0.0f) ? value / _totalTime : 1.0f;
}

- (float) currentPercentage { return (_reverse) ? 1.0f - _percentage : _percentage; }
- (void) setCurrentPercentage:(float)value
{
	value = (_reverse) ? 1.0f - value : value;
	_percentage = NPPClamp(value, 0.0f, 1.0f);
	_startTime = nppApplicationTime() - (_totalTime * _percentage);
	[self timerCallBack];
}

- (id) initWithTotalTime:(NSTimeInterval)time
{
	if ((self = [super init]))
	{
		self.totalTime = time;
	}
	
	return self;
}

- (void) setCurrentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total
{
	// Total must be set first.
	self.totalTime = total;
	self.currentTime = current;
}

- (void) start
{
	_startTime = nppApplicationTime() - (_totalTime * _percentage);
	
	[[NPPTimer instance] addItem:self];
	
	[self timerCallBack];
}

- (void) stop
{
	[[NPPTimer instance] removeItem:self];
}

- (void) reset
{
	_startTime = nppApplicationTime();
	_percentage = 0.0f;
	
	[self timerCallBack];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	[self stop];
	self.delegate = nil;
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
