/*
 *	NPPBaseGestureRecognizer.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 5/22/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"

@class NPPBaseGestureRecognizer;

typedef void (^NPPBlockGesture)(UIGestureRecognizer *gesture);

@interface UIGestureRecognizer (NPPGestureRecognizer)

- (id) initWithBlock:(NPPBlockGesture)block;
+ (id) recognizerWithBlock:(NPPBlockGesture)block;

@property (nonatomic, NPP_COPY) NPPBlockGesture gestureBlock;

@end

@interface NPPBaseGestureRecognizer : UIGestureRecognizer
{
@private
	UIGestureRecognizerState	_state;
	NSSet						*_touches;
	UIEvent						*_event;
	
	BOOL						_delaysSingleTouch;
	BOOL						_hasDelayed;
}

@property (nonatomic) BOOL delaysSingleTouch;
@property (nonatomic, readonly) NSArray *touches;

@property (nonatomic, readonly) CGPoint translation;	// Translation of 1st touch.
@property (nonatomic, readonly) float rotation;			// Rotation in degrees.
@property (nonatomic, readonly) float scale;			// Scale relative to start in screen coordinates.
@property (nonatomic, readonly) CGPoint translationIncrement;
@property (nonatomic, readonly) float rotationIncrement;
@property (nonatomic, readonly) float scaleIncrement;
@property (nonatomic, readonly) CGPoint translationVelocity;
@property (nonatomic, readonly) float rotationVelocity;
@property (nonatomic, readonly) float scaleVelocity;

@end