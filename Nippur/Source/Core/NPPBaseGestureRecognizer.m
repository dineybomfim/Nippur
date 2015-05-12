/*
 *	NPPBaseGestureRecognizer.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 5/22/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPBaseGestureRecognizer.h"

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

@interface UITouch(NPPTouch)

@end

@implementation UITouch(NPPTouch)

NPP_CATEGORY_PROPERTY(OBJC_ASSOCIATION_RETAIN_NONATOMIC, NSValue *, startingPoint, setStartingPoint);
NPP_CATEGORY_PROPERTY(OBJC_ASSOCIATION_RETAIN_NONATOMIC, NSNumber *, lastTimestamp, setLastTimestamp);

@end

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static CGPoint nppGestureTranslation(NSArray *touches, BOOL rel)
{
	UITouch *touch = [touches firstObject];
	UIView *view = [touch view];
	CGPoint current = [touch locationInView:view];
	CGPoint previous = (rel) ? [touch previousLocationInView:view] : [[touch startingPoint] CGPointValue];
	CGPoint vector = (CGPoint){ current.x - previous.x, current.y - previous.y };
	
	return vector;
}

static float nppGestureRotation(NSArray *touches, BOOL rel)
{
	float angle = 0.0f;
	
	if ([touches count] > 1)
	{
		UITouch *tA = [touches firstObject];
		UITouch *tB = [touches objectAtIndex:1];
		UIView *view = [tA view];
		CGPoint currentA = [tA locationInView:view];
		CGPoint previousA = (rel) ? [tA previousLocationInView:view] : [[tA startingPoint] CGPointValue];
		CGPoint currentB = [tB locationInView:view];
		CGPoint previousB = (rel) ? [tB previousLocationInView:view] : [[tB startingPoint] CGPointValue];
		double xDiff = currentA.x - currentB.x;
		double yDiff = currentA.y - currentB.y;
		double xInitDiff = previousA.x - previousB.x;
		double yInitDiff = previousA.y - previousB.y;
		float initAngle = kNPP_PI + atan2f(yInitDiff, xInitDiff);
		
		// Using 360" reference (2PI), finds the angle diff between the start and the current position.
		angle = kNPP_PI + atan2f(yDiff, xDiff);
		angle = angle - initAngle;
		angle = (angle < 0.0f) ? kNPP_2PI + angle : (angle > kNPP_2PI) ? angle - kNPP_2PI : angle;
	}
	
	return NPPRadiansToDegrees(angle);
}

static float nppGestureScale(NSArray *touches, BOOL rel)
{
	float scale = 0.0f;
	
	if ([touches count] > 1)
	{
		UITouch *tA = [touches firstObject];
		UITouch *tB = [touches objectAtIndex:1];
		UIView *view = [tA view];
		CGPoint currentA = [tA locationInView:view];
		CGPoint previousA = (rel) ? [tA previousLocationInView:view] : [[tA startingPoint] CGPointValue];
		CGPoint currentB = [tB locationInView:view];
		CGPoint previousB = (rel) ? [tB previousLocationInView:view] : [[tB startingPoint] CGPointValue];
		float currentDistance = nppPointsDistance(currentA, currentB);
		float previousDistance = nppPointsDistance(previousA, previousB);
		
		scale = (previousDistance != 0.0f) ? currentDistance / previousDistance : 0.0f;
	}
	
	return scale;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPBaseGestureRecognizer()

// Initializes a new instance.
- (void) initializing;

- (void) touchCallback;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPBaseGestureRecognizer

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize delaysSingleTouch = _delaysSingleTouch;

@dynamic touches, translation, rotation, scale, translationIncrement, rotationIncrement, scaleIncrement,
		 translationVelocity, rotationVelocity, scaleVelocity;

- (NSArray *) touches
{
	return [_touches allObjects];
}

- (CGPoint) translation
{
	return nppGestureTranslation([_touches allObjects], NO);
}

- (float) rotation
{
	return nppGestureRotation([_touches allObjects], NO);
}

- (float) scale
{
	return nppGestureScale([_touches allObjects], NO);
}

- (CGPoint) translationIncrement
{
	return nppGestureTranslation([_touches allObjects], YES);
}

- (float) rotationIncrement
{
	return nppGestureRotation([_touches allObjects], YES);
}

- (float) scaleIncrement
{
	return nppGestureScale([_touches allObjects], YES) - 1.0f;
}

- (CGPoint) translationVelocity
{
	CGPoint velocity = CGPointZero;
	NSArray *touches = [_touches allObjects];
	UITouch *touch = [touches firstObject];
	double lastTime = [[touch lastTimestamp] doubleValue];
	double currentTime = [touch timestamp];
	double delta = currentTime - lastTime;
	delta = (delta != 0.0) ? delta : 0.0;
	
	// Time in seconds, calculating the velocity in pixels/second.
	velocity = nppGestureTranslation(touches, YES);
	velocity.x /= delta;
	velocity.y /= delta;
	
	return velocity;
}

- (float) rotationVelocity
{
	float velocity = 0.0f;
	NSArray *touches = [_touches allObjects];
	UITouch *touch = [touches firstObject];
	double lastTime = [[touch lastTimestamp] doubleValue];
	double currentTime = [touch timestamp];
	double delta = currentTime - lastTime;
	delta = (delta != 0.0) ? delta : 0.0;
	
	// Time in seconds, calculating the velocity in pixels/second.
	velocity = nppGestureRotation(touches, YES);
	velocity /= delta;
	
	return velocity;
}

- (float) scaleVelocity
{
	float velocity = 0.0f;
	NSArray *touches = [_touches allObjects];
	UITouch *touch = [touches firstObject];
	double lastTime = [[touch lastTimestamp] doubleValue];
	double currentTime = [touch timestamp];
	double delta = currentTime - lastTime;
	delta = (delta != 0.0) ? delta : 0.0;
	
	// Time in seconds, calculating the velocity in pixels/second.
	velocity = nppGestureScale(touches, YES) - 1.0f;
	velocity /= delta;
	
	return velocity;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithTarget:nil action:Nil]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithTarget:(id)target action:(SEL)action
{
	if ((self = [super initWithTarget:target action:action]))
	{
		[self initializing];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	self.cancelsTouchesInView = NO;
}

- (void) touchCallback
{
	// Delay single touch.
	if (_delaysSingleTouch && !_hasDelayed && [_touches count] == 1)
	{
		// For pan gesture.
		if (nppPointsDistance(CGPointZero, [self translation]) > 15.0f)
		{
			UIGestureRecognizerState state = _state;
			NPPBlockGesture block = self.gestureBlock;
			
			_state = UIGestureRecognizerStateBegan;
			nppBlock(block, self);
			
			_state = state;
			nppBlock(block, self);
			
			_hasDelayed = YES;
		}
	}
	else
	{
		NPPBlockGesture block = self.gestureBlock;
		nppBlock(block, self);
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (UIGestureRecognizerState) state
{
	return _state;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_touches = [event allTouches];//touches;
	_event = event;
	
	// Adding the starting point reference to the touch.
	UITouch *touch = nil;
	UIView *targetView = nil;
	CGPoint location = CGPointZero;
	
	for (touch in _touches)
	{
		targetView = [touch view];
		location = [touch locationInView:targetView];
		[touch setStartingPoint:[NSValue valueWithCGPoint:location]];
		[touch setLastTimestamp:[NSNumber numberWithDouble:touch.timestamp]];
	}
	
	_state = UIGestureRecognizerStateBegan;
	[self touchCallback];
	
	_touches = nil;
	_event = nil;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	_touches = [event allTouches];//touches;
	_event = event;
	
	_state = UIGestureRecognizerStateChanged;
	[self touchCallback];
	
	// Adding the last timestamp reference to the touch.
	UITouch *touch = nil;

	for (touch in _touches)
	{
		[touch setLastTimestamp:[NSNumber numberWithDouble:touch.timestamp]];
	}
	
	_touches = nil;
	_event = nil;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	_touches = [event allTouches];//touches;
	_event = event;
	
	_state = UIGestureRecognizerStateEnded;
	[self touchCallback];
	
	_state = UIGestureRecognizerStatePossible;
	_touches = nil;
	_event = nil;
	_hasDelayed = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void) reset
{
	// Do nothing here.
}

- (void) ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
	// Do nothing here.
}

- (BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	return NO;
}

- (BOOL) canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	return NO;
}

- (NSString *) description
{
	NSString *description = [NSString stringWithFormat:@"%@State:%i\nTouches:%@\nEvents:%@",
							 [super description],
							 (int)_state,
							 _touches,
							 _event];
	
	return description;
}

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

#pragma mark -
#pragma mark UIGestureRecognizer Category
#pragma mark -
//**********************************************************************************************************
//
//	UIGestureRecognizer Category
//
//**********************************************************************************************************

@implementation UIGestureRecognizer (NPPGestureRecognizer)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

NPP_CATEGORY_PROPERTY(OBJC_ASSOCIATION_COPY_NONATOMIC, NPPBlockGesture, gestureBlock, setGestureBlock);

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithBlock:(NPPBlockGesture)block
{
	if ((self = [self initWithTarget:self action:@selector(handleGesture:)]))
	{
		self.gestureBlock = block;
	}
	
	return self;
}

+ (id) recognizerWithBlock:(NPPBlockGesture)block
{
	UIGestureRecognizer *gesture = [[self alloc] initWithBlock:block];
	
	return nppAutorelease(gesture);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) handleGesture:(UIGestureRecognizer *)recognizer
{
	NPPBlockGesture handler = recognizer.gestureBlock;
	
	if (handler == nil)
	{
		return;
	}
	
	nppBlock(handler, self);
}

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

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end
