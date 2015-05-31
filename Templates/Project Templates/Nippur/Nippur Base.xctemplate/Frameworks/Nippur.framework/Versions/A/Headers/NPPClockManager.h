/*
 *	NPPClockManager.h
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

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPTimer.h"

@class NPPClockManager;

/*!
 *					Defines the structure of a delegate to receive clock updates.
 */
@protocol NPPClockingDelegate <NSObject>

@required

/*!
 *					This method is called by the clock manager at every clock tick (usually 60 fps).
 *
 *	@param			clockController
 *					The #NPPClockManager# which has started this update.
 */
- (void) clockDidUpdate:(NPPClockManager *)clockController;

@end

/*!
 *					Defines a clocking object. Any class can implement those methods to become a
 *					clock manager.
 */
@protocol NPPClocking <NSObject>

@optional

/*!
 *					Reverse the clocking direction (forward or reward).
 */
@property (nonatomic) BOOL reverse;

/*!
 *					The total time for this clock.
 */
@property (nonatomic) NSTimeInterval totalTime;

/*!
 *					The current time for this clock.
 */
@property (nonatomic) NSTimeInterval currentTime;

/*!
 *					The current percentage for this clock.
 */
@property (nonatomic) float currentPercentage;

/*!
 *					The delegate, which will receive the clock update.
 */
@property (nonatomic, NPP_ASSIGN) id <NPPClockingDelegate> delegate;

/*!
 *					Inits a new instance with the total time.
 *
 *	@param			time
 *					The total time.
 */
- (id) initWithTotalTime:(NSTimeInterval)time;

/*!
 *					Sets the current time and the total time.
 *
 *	@param			current
 *					The current time.
 *
 *	@param			time
 *					The total time.
 */
- (void) setCurrentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total;

@required

/*!
 *					Starts the clock.
 */
- (void) start;

/*!
 *					Stops the clock in the current time.
 */
- (void) stop;

/*!
 *					Resets the clock to its initial state.
 */
- (void) reset;

@end

/*!
 *					The #NPPClockManager# is the concrete implementation of the #NPPClocking# interface.
 *
 *					This controller is capable to hold it self while the clock is ticking. Once the
 *					#stop# method is called, this strong bound is no longer granted, which means you must
 *					hold this controller if you intend to pause/resume its timing.
 */
@interface NPPClockManager : NSObject <NPPTimerItem, NPPClocking>
{
@private
	NPP_ARC_ASSIGN id <NPPClockingDelegate>	_delegate;
	BOOL						_reverse;
	NSTimeInterval				_totalTime;
	NSTimeInterval				_startTime;
	float						_percentage;
}

@end