/*
 *	NPPTimer.m
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

#import "NPPTimer.h"
#import "NPPThread.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//  Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//  Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

// The wakeup time.
static double _wakeupTime;

// The background time.
static double _backgroundTime;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPTimer()

// Setup the timer.
- (void) setupTimer;

// The timer cycle.
- (void) timerCycle:(NSTimer *)timer;

// Application states.
//- (void) pauseHandler:(NSNotification *)notification;
//- (void) resumeHandler:(NSNotification *)notification;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//  Public Interface
//
//**********************************************************************************************************

double nppApplicationTime(void)
{
	return nppAbsoluteTime() - _wakeupTime - _backgroundTime;
}

@implementation NPPTimer

NPP_SINGLETON_IMPLEMENTATION(NPPTimer);

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic paused;

- (BOOL) isPaused { return _paused; }
- (void) setPaused:(BOOL)value
{
	if (_paused != value)
	{
		_paused = value;
		
		// Configure the timer.
		[self setupTimer];
	}
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		/*
		// Defines the notifications for the application state changes.
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		
		[center removeObserver:self];
		[center addObserver:self
				   selector:@selector(pauseHandler:)
					   name:UIApplicationDidEnterBackgroundNotification
					 object:nil];
		
		[center addObserver:self
				   selector:@selector(pauseHandler:)
					   name:UIApplicationWillTerminateNotification
					 object:nil];
		
		[center addObserver:self
				   selector:@selector(resumeHandler:)
					   name:UIApplicationWillEnterForegroundNotification
					 object:nil];
		//*/
		// Setup.
		_collection = [[NSMutableArray alloc] init];
		_safeCollection = [[NSMutableArray alloc] init];
		_backgroundTime = 0.0f;
		_wakeupTime = 0.0f;
		
		// Starts the loop.
		_paused = NO;
		[self setupTimer];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//  Private Methods
//**************************************************

- (void) setupTimer
{
	// Clear the old timer.
	[_dispatch invalidate];
	_dispatch = nil;
	
	// Starting over the timer.
	if (!_paused)
	{
		// Uses NSTimer instead the new CADisplayLink because that new class doesn't support
		// all kind of frame rates as 31, 29, 24 and others.
		_dispatch = [NSTimer scheduledTimerWithTimeInterval:NPP_CYCLE
													 target:self
												   selector:@selector(timerCycle:)
												   userInfo:nil
													repeats:YES];
		
		[[NSRunLoop currentRunLoop] addTimer:_dispatch forMode:NSRunLoopCommonModes];
	}
}

- (void) timerCycle:(NSTimer *)timer
{
	id <NPPTimerItem> item;
	unsigned int count = 0;
	
	// Looping through a safe collection.
	// This approach is required because even the NSEnumerator is not safe for changes during the loop.
	for (item in _safeCollection)
	{
		[item timerCallBack];
	}
	
	count = (unsigned int)[_collection count];
	
	// Updating the safe collection, if necessary.
	if (_hasChanges)
	{
		[_safeCollection setArray:_collection];
		_hasChanges = NO;
	}
	
	if (count == 0)
	{
		self.paused = YES;
	}
}
/*
- (void) pauseHandler:(NSNotification *)notification
{
	if (!nppApplicationHasAnyBackgroundMode())
	{
		self.paused = YES;
		
		// Holds the last absolute time.
		_backgroundTime = nppAbsoluteTime();
	}
}

- (void) resumeHandler:(NSNotification *)notification
{
	if (!nppApplicationHasAnyBackgroundMode())
	{
		// Adds a small increment to the wakeupTime with the difference since the last activity.
		_backgroundTime = nppAbsoluteTime() - _backgroundTime;
		_wakeupTime += _backgroundTime;
		_backgroundTime = 0.0;
		
		self.paused = NO;
	}
}
//*/
#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//  Self Public Methods
//**************************************************

- (void) addItem:(id <NPPTimerItem>)item
{
	if ([_collection indexOfObject:item] == NSNotFound)
	{
		[_collection addObject:item];
		self.paused = NO;
		_hasChanges = YES;
	}
}

- (void) removeItem:(id <NPPTimerItem>)item
{
	[_collection removeObject:item];
	_hasChanges = YES;
}

- (void) removeAll
{
	[_collection removeAllObjects];
	_hasChanges = YES;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//  Override Public Methods
//**************************************************

- (void) dealloc
{
	// Stops the timer.
	self.paused = YES;
	
	// Removes the notifications.
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Frees the memory.
	nppRelease(_collection);
	nppRelease(_safeCollection);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
