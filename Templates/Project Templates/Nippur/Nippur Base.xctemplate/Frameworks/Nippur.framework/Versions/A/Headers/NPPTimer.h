/*
 *	NPPTimer.h
 *	Nippur
 *	v1.0
 *
 *	Created by Diney Bomfim on 08/19/13.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPRuntime.h"

/*!
 *					Returns the time that the application is running given in seconds.
 *					This function just consider the running time, that means, it discards the
 *					background time so it's a reliable source for animations precise time count.
 *
 *	@result			A double data type representing the time.
 */
NPP_API double nppApplicationTime(void);

/*!
 *					This protocol defines the callback functions to every instance which makes use of the
 *					Timer API.
 *
 *					The default callback interval is defined by the constant NPP_MAX_FPS,
 *					which means the callback function will be called NPP_MAX_FPS times per second.
 */
@protocol NPPTimerItem <NSObject>

@required

/*!
 *					This method is automatically called when an object, which implements NPPTimerItem
 *					protocol, enters in the NinevehGL timer cycle. This method is called in the render
 *					thread, if the multithreading is enabled.
 */
- (void) timerCallBack;

@end

/*!
 *					This class creates a single unique loop running with the interval defined by the
 *					constant NPP_MAX_FPS in #NPPTimerItem#. The NPP_MAX_FPS represents the number of loop
 *					for each second. As the NPPTimer is a singleton class, it can't be instantiated.
 *
 *					The NPPTimer works like a library, holding the items with a retain message and
 *					calling the callback function inside each item through the loop cycles. The items must
 *					conform to the #NPPTimerItem# protocol to be added.
 *
 *					The loop will start automatically when the singleton instance is called by the first
 *					time. You can stop and restart the loop.
 */
@interface NPPTimer : NSObject
{
@private
	BOOL					_hasChanges;
	BOOL					_paused;
	NSTimer					*_dispatch;
	NSMutableArray			*_collection;
	NSMutableArray			*_safeCollection;
}

NPP_SINGLETON_INTERFACE(NPPTimer);

/*!
 *					Pauses or resumes the timer.
 *
 *					Set this property to YES if you want to pause the animation temporary. Set it to NO
 *					again to resume the timer.
 *
 *					Its default value is NO.
 */
@property (nonatomic, getter = isPaused) BOOL paused;

/*!
 *					Adds an item from the loop cycle.
 *
 *					The items can't be duplicated, NPPTimer automatically will ignore attempts to insert
 *					the same item more than one time.
 *
 *	@param			item
 *					The object to be added, it must conform to #NPPTimerItem# protocol.
 */
- (void) addItem:(id <NPPTimerItem>)item;

/*!
 *					Removes an item from the loop cycle.
 *
 *	@param			item
 *					The object to be removed, it must conform to #NPPTimerItem# protocol.
 */
- (void) removeItem:(id <NPPTimerItem>)item;

/*!
 *					Removes all items from the loop cycle.
 */
- (void) removeAll;

@end