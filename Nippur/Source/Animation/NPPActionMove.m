/*
 *	NPPActionMove.m
 *	Nippur
 *
 *	The Nippur is a framework for iOS to make daily work easier and more reusable.
 *	This Nippur contains many API and includes many wrappers to other Apple frameworks.
 *
 *	More information at the official web site: http://db-in.com/nippur
 *
 *	Created by Diney Bomfim on 8/12/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPActionMove.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define TWEEN_0_36			0.363636f
#define TWEEN_0_54			0.545454f
#define TWEEN_0_72			0.727272f
#define TWEEN_0_81			0.818181f
#define TWEEN_0_90			0.909090f
#define TWEEN_0_95			0.954545f
#define TWEEN_1_65			1.656565f
#define TWEEN_3_23			3.232323f
#define TWEEN_7_56			7.562525f

#define kNPPEncodeKey		@"key"
#define kNPPEncodeFrom		@"from"
#define kNPPEncodeTo		@"to"
#define kNPPEncodeType		@"type"

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

//*************************
//	Linear
//*************************

static float nppEaseLinear(float begin, float change, float time, float duration)
{
	return (change * time / duration) + begin;
}

//*************************
//	Smooth
//*************************

static float nppEaseSmoothOut(float begin, float change, float time, float duration)
{
	time /= duration;
	return -change * time * (time - 2.0f) + begin;
}

static float nppEaseSmoothIn(float begin, float change, float time, float duration)
{
	time /= duration;
	return change * time * time + begin;
}

static float nppEaseSmoothInOut(float begin, float change, float time, float duration)
{
	if ((time /= duration * 0.5f) < 1.0f)
	{
		return change * 0.5f * time * time + begin;
	}
	
	--time;
	return -change * 0.5f * ((time) * (time - 2.0f) - 1.0f) + begin;
}

//*************************
//	Strong
//*************************

static float nppEaseStrongOut(float begin, float change, float time, float duration)
{
	float power = -powf(2.0f, -10.0f * time / duration) + 1.0f;
	return (time == duration) ? begin + change : change * power + begin;
}

static float nppEaseStrongIn(float begin, float change, float time, float duration)
{
	if (time == 0.0f)
	{
		return begin;
	}
	
	return change * powf(2.0f, 10.0f * (time / duration - 1.0f)) + begin - change * 0.001f;
}

static float nppEaseStrongInOut(float begin, float change, float time, float duration)
{
	if (time == 0.0f)
	{
		return begin;
	}
	else if (time == duration)
	{
		return begin + change;
	}
	else if ((time /= duration * 0.5f) < 1.0f)
	{
		return change * 0.5f * powf(2.0f, 10.0f * --time) + begin;
	}
	
	return change * 0.5f * (-powf(2.0f, -10.0f * --time) + 2.0f) + begin;
}

//*************************
//	Elastic
//*************************

static float nppEaseElasticOut(float begin, float change, float time, float duration)
{
	float x = change, y = duration * 0.3f, z = y / 4.0f;
	
	if (time == 0.0f)
	{
		return begin;
	}
	else if ((time /= duration) == 1.0f)
	{
		return begin + change;
	}
	
	return x * powf(2.0f, -10.0f * time) * sinf((time * duration - z) * kNPP_2PI / y) + change + begin;
}

static float nppEaseElasticIn(float begin, float change, float time, float duration)
{
	float x = change, y = duration * 0.3f, z = y / 4.0f;
	
	if (time == 0.0f)
	{
		return begin;
	}
	else if ((time /= duration) == 1.0f)
	{
		return begin + change;
	}
	
	--time;
	return -x * powf(2.0f, 10.0f * time) * sinf((time * duration - z) * kNPP_2PI / y) + begin;
}

static float nppEaseElasticInOut(float begin, float change, float time, float duration)
{
	float x = change, y = duration * 0.45f, z = y / 4.0f, powTime;
	
	if (time == 0.0f)
	{
		return begin;
	}
	else if ((time /= duration * 0.5f) == 2.0f)
	{
		return begin + change;
	}
	
	if (time < 1.0)
	{
		powTime = powf(2.0f, 10.0f * --time);
		return -0.5f * x * powTime * sinf((time * duration - z ) * kNPP_2PI / y) + begin;
	}
	
	powTime = powf(2.0f, -10.0f * --time);
	return 0.5f * x * powTime * sinf((time * duration - z) * kNPP_2PI / y) + change + begin;
}

//*************************
//	Bounce
//*************************

static float nppEaseBounceOut(float begin, float change, float time, float duration)
{
	time /= duration;
	
	if (time < TWEEN_0_36)
	{
		return change * (TWEEN_7_56 * time * time) + begin;
	}
	else if (time < TWEEN_0_72)
	{
		time -= TWEEN_0_54;
		return change * (TWEEN_7_56 * time * time + 0.75f) + begin;
	}
	else if (time < TWEEN_0_90)
	{
		time -= TWEEN_0_81;
		return change * (TWEEN_7_56 * time * time + 0.9375f) + begin;
	}
	
	time -= 0.963636f;
	return change * (TWEEN_7_56 * time * time + 0.99f) + begin;
}

static float nppEaseBounceIn(float begin, float change, float time, float duration)
{
	return change - nppEaseBounceOut(0.0f, change, duration - time, duration) + begin;
}

static float nppEaseBounceInOut(float begin, float change, float time, float duration)
{
	if (time < duration * 0.5f)
	{
		return nppEaseBounceIn(0.0f, change, time * 2.0f, duration) * 0.5f + begin;
	}
	
	return nppEaseBounceOut(0.0f, change, time * 2.0f - duration, duration) * 0.5f + change * 0.5f + begin;
}

//*************************
//	Back
//*************************

static float nppEaseBackOut(float begin, float change, float time, float duration)
{
	time = time / duration - 1.0f;
	return change * (time * time * ((TWEEN_1_65 + 1.0f) * time + TWEEN_1_65) + 1.0f) + begin;
}

static float nppEaseBackIn(float begin, float change, float time, float duration)
{
	time /= duration;
	return change * time * time * ((TWEEN_1_65 + 1.0f) * time - TWEEN_1_65) + begin;
}

static float nppEaseBackInOut(float begin, float change, float time, float duration)
{
	if ((time /= duration * 0.5f) < 1.0f)
	{
		return change * 0.5f * (time * time * ((TWEEN_3_23 + 1.0f) * time - TWEEN_3_23)) + begin;
	}
	
	time -= 2.0f;
	return change * 0.5f * (time * time * ((TWEEN_3_23 + 1.0f) * time + TWEEN_3_23) + 2.0f) + begin;
}

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

@implementation NPPActionMove

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

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

- (void) setKey:(NSString *)key from:(float)fromValue to:(float)toValue type:(NPPMoveType)type
{
	NPPBlockAction block = nil;
	__block __typeof__(self) bself = self;
	
	nppRelease(_key);
	_key = nppRetain(key);
	_from = fromValue;
	_to = toValue;
	_type = type;
	
	// Initializing the tracker dictionary.
	nppRelease(_tracker);
	_tracker = [[NSMutableDictionary alloc] init];
	
	//TODO relatives.
	//fromValue = (isRelative) ? fromValue + [object floatValue] : fromValue;
	//toValue = (isRelative) ? toValue + [object floatValue] : toValue;
	
	//TODO Starts immediately.
	//[currentTarget setValue:[NSNumber numberWithFloat:from] forKeyPath:key];
	
	block = ^(id currentTarget, float elapsedTime, double token)
	{
		float from = 0.0f;
		float to = 0.0f;
		NSString *address = nil;
		NSNumber *origin = nil;
		float duration = bself->_time.finalDuration;
		
		// Avoiding redundant calls and finished targets.
		elapsedTime = MIN(elapsedTime, duration);
		
		if (type != NPPMoveTypeFromTo)
		{
			// Use the memory address' string as the dictionary key.
			address = [NSString stringWithFormat:@"%.16g", token];
			
			// Gets the original value.
			origin = [bself->_tracker objectForKey:address];
			
			// If there is no original value yet, set it.
			if (origin == nil)
			{
				origin = [currentTarget valueForKeyPath:key];
				[bself->_tracker setObject:origin forKey:address];
			}
		}
		
		// Choose the appropriate tween type.
		switch (type)
		{
			//*************************
			//	By
			//*************************
			case NPPMoveTypeBy:
				from = [origin floatValue];
				to = from + (toValue * duration * NPP_MAX_FPS);
				break;
			//*************************
			//	To
			//*************************
			case NPPMoveTypeTo:
				from = [origin floatValue];
				to = toValue;
				break;
			//*************************
			//	From
			//*************************
			case NPPMoveTypeFrom:
				from = fromValue;
				to = [origin floatValue];
				break;
			//*************************
			//	From - To
			//*************************
			case NPPMoveTypeFromTo:
			default:
				from = fromValue;
				to = toValue;
				break;
		}
		
		// Making the movement.
		float begin = from;
		float delta = to - from;
		float actual = (duration == 0.0f) ? to : bself->_easingFunc(begin, delta, elapsedTime, duration);
		
		[currentTarget setValue:[NSNumber numberWithFloat:actual] forKeyPath:key];
		
		// Ending setup.
		if (elapsedTime >= duration && type != NPPMoveTypeFromTo)
		{
			[bself->_tracker removeObjectForKey:address];
		}
	};
	
	self.actionBlock = block;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

#pragma mark -
#pragma mark NSCoding
//*************************
//	NSCoding
//*************************

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSString *key = [aDecoder decodeObjectForKey:kNPPEncodeKey];
		float from = [aDecoder decodeFloatForKey:kNPPEncodeFrom];
		float to = [aDecoder decodeFloatForKey:kNPPEncodeTo];
		NPPMoveType type = [aDecoder decodeIntForKey:kNPPEncodeType];
		
		[self setKey:key from:from to:to type:type];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:_key forKey:kNPPEncodeKey];
	[aCoder encodeFloat:_from forKey:kNPPEncodeFrom];
	[aCoder encodeFloat:_to forKey:kNPPEncodeTo];
	[aCoder encodeInt:_type forKey:kNPPEncodeType];
}

#pragma mark -
#pragma mark NSCopying
//*************************
//	NSCopying
//*************************

- (id) copyWithZone:(NSZone *)zone
{
	NPPActionMove *copy = [super copyWithZone:zone];
	
	// Copying properties.
	[copy setKey:_key from:_from to:_to type:_type];
	
	return copy;
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (NPPAction *) reversed
{
	float from = 0.0f;
	float to = 0.0f;
	NPPMoveType type = _type;
	
	// Choose the appropriate tween type.
	// Attention with the reverse of TO move behavior.
	switch (_type)
	{
		case NPPMoveTypeBy:
			to = -_to;
			break;
		case NPPMoveTypeTo:
			type = NPPMoveTypeFrom;
			from = _to;
			break;
		case NPPMoveTypeFrom:
			type = NPPMoveTypeTo;
			to = _from;
			break;
		case NPPMoveTypeFromTo:
		default:
			to = _from;
			from = _to;
			break;
	}
	
	// Creating the new reversed action.
	NPPActionMove *action = [[[self class] alloc] init];
	action.duration = _time.duration;
	action.speed = _time.speed;
	action.ease = _ease;
	[action setKey:_key from:from to:to type:type];
	
	return nppAutorelease(action);
}

- (void) setEase:(NPPActionEase)value
{
	_ease = value;
	
	switch (value)
	{
		case NPPActionEaseSmoothIn:
			_easingFunc = &nppEaseSmoothIn;
			break;
		case NPPActionEaseSmoothOut:
			_easingFunc = &nppEaseSmoothOut;
			break;
		case NPPActionEaseSmoothInOut:
			_easingFunc = &nppEaseSmoothInOut;
			break;
		case NPPActionEaseStrongIn:
			_easingFunc = &nppEaseStrongIn;
			break;
		case NPPActionEaseStrongOut:
			_easingFunc = &nppEaseStrongOut;
			break;
		case NPPActionEaseStrongInOut:
			_easingFunc = &nppEaseStrongInOut;
			break;
		case NPPActionEaseElasticIn:
			_easingFunc = &nppEaseElasticIn;
			break;
		case NPPActionEaseElasticOut:
			_easingFunc = &nppEaseElasticOut;
			break;
		case NPPActionEaseElasticInOut:
			_easingFunc = &nppEaseElasticInOut;
			break;
		case NPPActionEaseBounceIn:
			_easingFunc = &nppEaseBounceIn;
			break;
		case NPPActionEaseBounceOut:
			_easingFunc = &nppEaseBounceOut;
			break;
		case NPPActionEaseBounceInOut:
			_easingFunc = &nppEaseBounceInOut;
			break;
		case NPPActionEaseBackIn:
			_easingFunc = &nppEaseBackIn;
			break;
		case NPPActionEaseBackOut:
			_easingFunc = &nppEaseBackOut;
			break;
		case NPPActionEaseBackInOut:
			_easingFunc = &nppEaseBackInOut;
			break;
		case NPPActionEaseLinear:
		default:
			_easingFunc = &nppEaseLinear;
			break;
	}
}

- (NSString *) description
{
	NSMutableString *string = [NSMutableString stringWithString:[super description]];
	
	[string appendFormat:@"{"];
	[string appendFormat:@" key: %@", _key];
	
	switch (_type)
	{
		case NPPMoveTypeBy:
			[string appendFormat:@" by: %f", _to];
			break;
		case NPPMoveTypeTo:
			[string appendFormat:@" to: %f", _to];
			break;
		case NPPMoveTypeFrom:
			[string appendFormat:@" from: %f", _from];
			break;
		case NPPMoveTypeFromTo:
		default:
			[string appendFormat:@" from: %f", _from];
			[string appendFormat:@" to: %f", _to];
			break;
	}
	
	[string appendFormat:@" }"];
	
	return string;
}

- (void) dealloc
{
	nppRelease(_tracker);
	nppRelease(_key);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end