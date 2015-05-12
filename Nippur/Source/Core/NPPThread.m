/*
 *	NPPThread.m
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

#import "NPPThread.h"

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

//*************************
//	Thread Task
//*************************

/*!
 *					<strong>(Internal only)</strong> Helps to hold and manage tasks into a thread.
 */
@interface NPPThreadTask : NSObject

@property (nonatomic, NPP_RETAIN) id target;
@property (nonatomic) SEL selector;

- (id) initWithTarget:(id)target selector:(SEL)selector;

- (void) execute;

@end

@implementation NPPThreadTask

@synthesize target = _target, selector = _selector;

- (id) initWithTarget:(id)target selector:(SEL)selector
{
	if ((self = [super init]))
	{
		self.target = target;
		self.selector = selector;
	}
	
	return self;
}

- (void) execute
{
	nppPerformAction(_target, _selector);
}

- (void) dealloc
{
	nppRelease(_target);
	_selector = nil;
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// The threads single access point.
NPP_STATIC_READONLY(nppGetThreads, NSMutableDictionary);

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPThread()

- (void) spawnThread;

- (void) killThread;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

NPPThread *nppThreadGet(NSString *name)
{
	NPPThread *thread = [nppGetThreads() objectForKey:name];
	
	// Just start new threads. Old threads will be reused.
	if (thread == nil)
	{
		// The thread is retained internally by the NPPThread and will be released only when it exit.
		thread = nppAutorelease([[NPPThread alloc] initWithName:name]);
	}
	
	return thread;
}

void nppThreadPerformAsync(NSString *name, SEL selector, id target)
{
	// Creates the thread once, if necessary.
	NPPThread *thread = nppThreadGet(name);
	[thread setType:NPPThreadTypeAutoExit];
	[thread performAsync:selector target:target];
}

void nppThreadPerformSync(NSString *name, SEL selector, id target)
{
	// Creates the thread once, if necessary.
	NPPThread *thread = nppThreadGet(name);
	[thread setType:NPPThreadTypeAutoExit];
	[thread performSync:selector target:target];
}

void nppThreadExit(NSString *name)
{
	[[nppGetThreads() objectForKey:name] killThread];
}

void nppThreadExitAll(void)
{
	NSDictionary *running = [nppGetThreads() copy];
	NSString *threadName = nil;
	
	// Kills all threads.
	for (threadName in running)
	{
		nppThreadExit(threadName);
	}
	
	nppRelease(running);
	
	if ([NSThread isMainThread])
	{
		// Stuck while the threads are exiting.
		while ([nppGetThreads() count] > 0)
		{
			usleep(NPP_CYCLE_USEC);
		}
	}
}

@implementation NPPThread

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize name = _name, thread = _thread, alive = _alive, paused = _paused, type = _type;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithName:(NSString *)name
{
	if ((self = [super init]))
	{
		// Settings.
		_name = [name copy];
		_hasChanges = NO;
		_paused = NO;
		_type = NPPThreadTypeNormal;
		
		// The threads are internally retained to make future changes on it.
		[nppGetThreads() setObject:self forKey:_name];
		
		_collection = [[NSMutableArray alloc] init];
		_safeCollection = [[NSMutableArray alloc] init];
		_thread = [[NSThread alloc] initWithTarget:self selector:@selector(spawnThread) object:nil];
		_thread.name = _name;
		[_thread start];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) spawnThread
{
	// Thread settings.
	_alive = YES;
	
	// Task settings.
	NPPThreadTask *task = nil;
	BOOL oneTaskDone = NO;
	
	// Thread routine
	while (_alive)
	{
		// Ignores thread processing when paused.
		if (_paused)
		{
			continue;
		}
		
#ifndef NPP_ARC
		// Autorelease pool.
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
		// The thread's run loop. When there is no timer or sources in the run loop it will not wait the
		// NPP cycle (in seconds), so this thread must sleep for a NPP cycle.
		if (CFRunLoopRunInMode(kCFRunLoopDefaultMode, NPP_CYCLE, NO) == kCFRunLoopRunFinished)
		{
			usleep(NPP_CYCLE_USEC);
		}
		
		switch (_type)
		{
			case NPPThreadTypeContinuous:
				if (_hasChanges)
				{
					_hasChanges = NO;
					[_safeCollection setArray:_collection];
				}
				break;
			default:
				_hasChanges = NO;
				[_safeCollection setArray:_collection];
				[_collection removeAllObjects];
				break;
		}
		
		// Processes the Objc-C messages and frees the previous allocated memory for the message.
		// First-in First-out rule. The first item will be detached, so the iterator "doesn't move".
		for (task in _safeCollection)
		{
			// Executes the Obj-C message as fast as possible.
			[task execute];
			
			// Defines one task done.
			oneTaskDone = YES;
		}
		
#ifndef NPP_ARC
		// Draining the pool.
		nppRelease(pool);
#endif
		
		// The autoExit and changed status will wait for at least one task be done.
		if (oneTaskDone)
		{
			// Autoexit thread after processing the queue.
			if (_type == NPPThreadTypeAutoExit && [_collection count] == 0)
			{
				[self killThread];
			}
		}
	}
	
	// Freeing the non-used memory and exiting thread.
	[self removeAllTasks];
}

- (void) killThread
{
	// The thread will exit its entry point routine normally. This is the best approach.
	// The running thread will complete its current queue.
	_alive = NO;
	[nppGetThreads() removeObjectForKey:_name];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) performAsync:(SEL)selector target:(id)target
{
	NPPThreadTask *task = [[NPPThreadTask alloc] initWithTarget:target selector:selector];
	
	// Adds the new task and change the status.
	[_collection addObject:task];
	_hasChanges = YES;
}

- (void) performSync:(SEL)selector target:(id)target
{
	// If the target thread is not the current thread, waits until the task is finished.
	if (_thread != [NSThread currentThread])
	{
		[self performAsync:selector target:target];
		
		// Waiting for the task be performed.
		while (_hasChanges)
		{
			usleep(NPP_CYCLE_USEC);
		}
	}
	// If the target thread is the current thread, just performs the task.
	else
	{
		nppPerformAction(target, selector);
	}
}

- (void) removeAllTasksForTarget:(id)target
{
	NPPThreadTask *task = nil;
	NSArray *safeCollection = [NSArray arrayWithArray:_collection];
	
	// Searches for all occurrences of the target.
	for (task in safeCollection)
	{
		if (task.target == target)
		{
			[_collection removeObject:task];
		}
	}
	
	_hasChanges = YES;
}

- (void) removeAllTasks
{
	[_collection removeAllObjects];
	_hasChanges = YES;
}

- (void) exit
{
	[self killThread];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	// Doesn't need to exit the NPPThread because the dealloc can't be called while the thread is alive.
	
	nppRelease(_name);
	nppRelease(_collection);
	nppRelease(_safeCollection);
	nppRelease(_thread);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end