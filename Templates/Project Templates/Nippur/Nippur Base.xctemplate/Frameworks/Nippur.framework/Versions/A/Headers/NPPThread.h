/*
 *	NPPThread.h
 *	Nippur
 *	v1.0
 *
 *	Created by Diney Bomfim on 08/19/13.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"

/*!
 *					The thread's type. It defines the life behavior of a thread.
 *
 *	@var			NPPThreadTypeNormal
 *					Usual thread behavior. It's long-lived and lasts until you explicit exit it.
 *					The tasks are performed once in the next cycle and never more.
 *
 *	@var			NPPThreadTypeAutoExit
 *					Special thread type also known as short-lived thread. It'll lasts only until the
 *					end of the current cycle. If this type is set before processing any task, it will
 *					wait for at least finish one successfully task.
 *
 *	@var			NPPThreadTypeContinuous
 *					Special thread, it's a long-lived thread. In this mode, the thread does not discard
 *					the tasks after processing it, instead it will retain any task and execute them again
 *					at every new cycle. In this mode, you must explicit remove a task or remove all.
 */
typedef enum
{
	NPPThreadTypeNormal,
	NPPThreadTypeAutoExit,
	NPPThreadTypeContinuous,
} NPPThreadType;

@class NPPThread;

/*!
 *					Returns a NPPThread with a specific name. This method will spawn a new threads if the
 *					name doesn't exit yet.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *
 *	@result			A NPPThread instance.
 */
NPP_API NPPThread *nppThreadGet(NSString *name);

/*!
 *					Adds an item into the queue of a NPPThread. It will be executed asynchronously.
 *
 *					This function will automatically create a short-lived thread if the specified name
 *					doesn't exist yet.
 *
 *					The items in the queue are retained to avoid bad accesses.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *	
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
NPP_API void nppThreadPerformAsync(NSString *name, SEL selector, id target);


/*!
 *					Executes a task synchronously on a NPPThread.
 *
 *					This function will automatically create a short-lived thread if the specified name
 *					doesn't exist yet.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
NPP_API void nppThreadPerformSync(NSString *name, SEL selector, id target);

/*!
 *					Immediately marks a NPPThread with a specific name to exit.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 */
NPP_API void nppThreadExit(NSString *name);

/*!
 *					Immediately exits all running threads.
 *
 *					If this function is called from the main thread it will wait for all threads end,
 *					working synchronously, if it's called from another thread it will work asynchronously.
 */
NPP_API void nppThreadExitAll(void);

/*!
 *					The
 */
@interface NPPThread : NSObject
{
@private
	NSString				*_name;
	NSThread				*_thread;
	BOOL					_alive, _paused;
	NPPThreadType			_type;
	NSMutableArray			*_collection;
	
	// Helpers
	BOOL					_hasChanges;
	NSMutableArray			*_safeCollection;
}

/*!
 *					The thread's name.
 */
@property (nonatomic, readonly) NSString *name;

/*!
 *					The NSThread instance.
 */
@property (nonatomic, readonly) NSThread *thread;

/*!
 *					Indicates if this thread is running. It'll return NO if the thread is not started yet
 *					or if it is finishing.
 */
@property (nonatomic, readonly, getter = isAlive) BOOL alive;

/*!
 *					Pauses or resumes this thread.
 *
 *					The default is NO.
 */
@property (nonatomic, getter = isPaused) BOOL paused;

/*!
 *					Defines the type of the current thread.
 *
 *					The default is NPPThreadTypeNormal.
 *
 *	@see			#NPPThreadType#
 */
@property (nonatomic) NPPThreadType type;

/*!
 *					Initializes a NPPThread instance with a name.
 *
 *					This method will be called to initialize NPPThread anyway. If the single
 *					<code>init</code> method is called, it will call this method with a blank name.
 *
 *	@param			name
 *					The name for this thread.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithName:(NSString *)name;

/*!
 *					Inserts a new item in the queue of this thread.
 *
 *					The items in the queue follow the First-in First-out rule, that means, when a new item
 *					enters in the queue, it assumes the last position and will be processed after all the
 *					current items.
 *
 *					The items in the queue are retained to avoid bad accesses.
 *
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
- (void) performAsync:(SEL)selector target:(id)target;

/*!
 *					Inserts a new item in the queue of this thread and wait until it is performed.
 *
 *					The items in the queue are retained to avoid bad accesses.
 *
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
- (void) performSync:(SEL)selector target:(id)target;

/*!
 *					Cancels all the pending requests for a specific target.
 *
 *	  @param		target
 *					The target object that was informed early in the #performAsync:target:# method.
 */
- (void) removeAllTasksForTarget:(id)target;

/*!
 *					Cancels all the pending requests to this thread.
 */
- (void) removeAllTasks;

/*!
 *					Immediately exit this thread, even if there is a pending queue. The pending queues will
 *					be cancelled.
 */
- (void) exit;

@end