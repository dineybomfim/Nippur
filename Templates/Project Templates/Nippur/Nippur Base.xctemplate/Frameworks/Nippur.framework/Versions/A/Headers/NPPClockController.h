/*
 *	NPPClockController.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 6/8/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPTimer.h"

@class NPPClockController;

@protocol NPPClockingDelegate <NSObject>

@required
- (void) clockDidUpdate:(NPPClockController *)clockController;

@end

@protocol NPPClocking <NSObject>

@optional
@property (nonatomic) BOOL reverse;
@property (nonatomic) NSTimeInterval totalTime;
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic) float currentPercentage;
@property (nonatomic, NPP_ASSIGN) id <NPPClockingDelegate> delegate;

- (id) initWithTotalTime:(NSTimeInterval)time;

- (void) setCurrentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total;

@required
- (void) start;
- (void) stop;
- (void) reset;

@end

@interface NPPClockController : NSObject <NPPTimerItem, NPPClocking>
{
@private
	NPP_ARC_ASSIGN id <NPPClockingDelegate>	_delegate;
	BOOL						_reverse;
	NSTimeInterval				_totalTime;
	NSTimeInterval				_startTime;
	float						_percentage;
}

@end