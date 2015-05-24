/*
 *	NPPAction.m
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

#import "NPPAction.h"

#import "NPPActionBlock.h"
#import "NPPActionGroup.h"
#import "NPPActionRepeat.h"
#import "NPPActionSelector.h"
#import "NPPActionSequence.h"
#import "NPPActionMove.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPActionPattern	@"action-%llu"
#define kNPPEncodeDuration	@"duration"
#define kNPPEncodeSpeed		@"speed"
#define kNPPEncodeEase		@"ease"

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

static NPPActionEase _defaultEase = NPPActionEaseLinear;

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

@interface NPPAction()

// Initializes a new instance.
- (void) initializing;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPAction

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic actionBlock, finalDuration, duration, speed, ease;

- (NPPBlockAction) actionBlock { return _actionBlock; }
- (void) setActionBlock:(NPPBlockAction)value
{
	nppRelease(_actionBlock);
	_actionBlock = [value copy];
}

- (NPPActionEase) ease { return _ease; }
- (void) setEase:(NPPActionEase)value
{
	_ease = value;
}

- (float) speed { return _time.speed; }
- (void) setSpeed:(float)value
{
	//TODO 0 = pause.
	_time.speed = value;
	_time.finalDuration = (_time.speed > 0.0f) ? _time.duration / _time.speed : _time.duration;
}

- (float) duration { return _time.duration; }
- (void) setDuration:(float)value
{
	//TODO 0 = pause.
	_time.duration = value;
	_time.finalDuration = (_time.speed > 0.0f) ? _time.duration / _time.speed : _time.duration;
}

- (float) finalDuration { return _time.finalDuration; }

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
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
	_time = kNPPActionTimeZero;
	self.ease = _defaultEase;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark NSCoding
//*************************
//	NSCoding
//*************************

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init]))
	{
		_time = kNPPActionTimeZero;
		self.duration = [aDecoder decodeFloatForKey:kNPPEncodeDuration];
		self.speed = [aDecoder decodeFloatForKey:kNPPEncodeSpeed];
		self.ease = [aDecoder decodeIntForKey:kNPPEncodeEase];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeFloat:_time.duration forKey:kNPPEncodeDuration];
	[aCoder encodeFloat:_time.speed forKey:kNPPEncodeSpeed];
	[aCoder encodeInt:_ease forKey:kNPPEncodeEase];
}

#pragma mark -
#pragma mark NSCopying
//*************************
//	NSCopying
//*************************

- (id) copyWithZone:(NSZone *)zone
{
	NPPAction *copy = [[[self class] allocWithZone:zone] init];
	
	// Copying properties.
	copy.duration = _time.duration;
	copy.speed = _time.speed;
	copy.ease = _ease;
	copy.actionBlock = _actionBlock;
	
	return copy;
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (NPPAction *) reversed
{
	NPPAction *action = [self copy];
	
	return nppAutorelease(action);
}

- (void) saveToFile:(NSString *)fileName
{
	[NPPDataManager saveFile:self name:fileName type:NPPDataTypeArchive folder:NPPDataFolderNippur];
}

+ (NPPAction *) actionFromFile:(NSString *)fileName
{
	NPPAction *action = nil;
	
	id object = [NPPDataManager loadFile:fileName type:NPPDataTypeArchive folder:NPPDataFolderNippur];
	
	if ([object isKindOfClass:self])
	{
		action = object;
	}
	
	return action;
}

+ (void) defineEasingMode:(NPPActionEase)ease
{
	_defaultEase = ease;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSMutableString *string = [NSMutableString string];
	
	[string appendFormat:@"<%@: %x;", NSStringFromClass([self class]), (unsigned int)self];
	[string appendFormat:@" duration: %f", _time.duration];
	[string appendFormat:@" speed: %f", _time.speed];
	[string appendString:@">"];
	
	return string;
}

- (void) dealloc
{
	nppRelease(_actionBlock);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end

#pragma mark -
#pragma mark NPPAction Category
#pragma mark -
//**********************************************************************************************************
//
//	NPPAction Category
//
//**********************************************************************************************************

@implementation NPPAction (NPPActions)

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

+ (NPPAction *) moveKey:(NSString *)key by:(float)byValue duration:(float)seconds
{
	NPPActionMove *action = [[NPPActionMove alloc] init];
	[action setKey:key from:0.0f to:byValue type:NPPMoveTypeBy];
	action.duration = seconds;
	
	return nppAutorelease(action);
}

+ (NPPAction *) moveKey:(NSString *)key to:(float)toValue duration:(float)seconds
{
	NPPActionMove *action = [[NPPActionMove alloc] init];
	[action setKey:key from:0.0f to:toValue type:NPPMoveTypeTo];
	action.duration = seconds;
	
	return nppAutorelease(action);
}

+ (NPPAction *) moveKey:(NSString *)key from:(float)fromValue duration:(float)seconds
{
	NPPActionMove *action = [[NPPActionMove alloc] init];
	[action setKey:key from:fromValue to:0.0f type:NPPMoveTypeFrom];
	action.duration = seconds;
	
	return nppAutorelease(action);
}

+ (NPPAction *) moveKey:(NSString *)key from:(float)fromValue to:(float)toValue duration:(float)seconds
{
	NPPActionMove *action = [[NPPActionMove alloc] init];
	[action setKey:key from:fromValue to:toValue type:NPPMoveTypeFromTo];
	action.duration = seconds;
	
	return nppAutorelease(action);
}

+ (NPPAction *) fadeIn
{
	return [self moveKey:@"alpha" to:1.0f duration:kNPPAnimTime];
}

+ (NPPAction *) fadeInUnhiding
{
	return [self sequence:@[ [self unhide], [self fadeIn] ]];
}

+ (NPPAction *) fadeOut
{
	return [self moveKey:@"alpha" to:0.0f duration:kNPPAnimTime];
}

+ (NPPAction *) fadeOutHiding
{
	return [self sequence:@[ [self fadeOut], [self hide] ]];
}

+ (NPPAction *) fadeOutRemoving
{
	return [self sequence:@[ [self fadeOut], [self removeFromSuperview] ]];
}

+ (NPPAction *) waitForDuration:(float)seconds
{
	NPPAction *action = [[self alloc] init];
	action.duration = seconds;
	
	return nppAutorelease(action);
}

+ (NPPAction *) removeFromSuperview
{
	return [self performSelector:@selector(removeFromSuperview) onTarget:nil];
}

+ (NPPAction *) toggleHidden
{
	return [self performSelector:@selector(toggleHidden) onTarget:nil];
}

+ (NPPAction *) hide
{
	NPPBlockAction block = ^(id currentTarget, float elapsedTime, double token)
	{
		if ([currentTarget respondsToSelector:@selector(setHidden:)])
		{
			[currentTarget setHidden:YES];
		}
	};
	
	return [self customActionWithDuration:0.0f actionBlock:block];
}

+ (NPPAction *) unhide
{
	NPPBlockAction block = ^(id currentTarget, float elapsedTime, double token)
	{
		if ([currentTarget respondsToSelector:@selector(setHidden:)])
		{
			[currentTarget setHidden:NO];
		}
	};
	
	return [self customActionWithDuration:0.0f actionBlock:block];
}

+ (NPPAction *) runBlock:(NPPBlockVoid)block
{
	NPPActionBlock *action = [[NPPActionBlock alloc] init];
	[action setBlock:block];
	
	return nppAutorelease(action);
}

+ (NPPAction *) performSelector:(SEL)selector onTarget:(id)target
{
	NPPActionSelector *action = [[NPPActionSelector alloc] init];
	[action setTarget:target selector:selector];
	
	return nppAutorelease(action);
}

+ (NPPAction *) repeatAction:(NPPAction *)action count:(unsigned int)count
{
	NPPActionRepeat *repeat = [[NPPActionRepeat alloc] init];
	[repeat setRepeatAction:action count:count];
	
	return nppAutorelease(repeat);
}

+ (NPPAction *) repeatActionForever:(NPPAction *)action
{
	return [self repeatAction:action count:NPP_MAX_32];
}

+ (NPPAction *) sequence:(NSArray *)actions
{
	NPPActionSequence *collection = [[NPPActionSequence alloc] init];
	[collection setSequence:actions];
	
	return nppAutorelease(collection);
}

+ (NPPAction *) group:(NSArray *)actions
{
	NPPActionGroup *collection = [[NPPActionGroup alloc] init];
	[collection setGroup:actions];
	
	return nppAutorelease(collection);
}

+ (NPPAction *) customActionWithDuration:(float)seconds actionBlock:(NPPBlockAction)block
{
	NPPAction *action = [[self alloc] init];
	action.duration = seconds;
	action.actionBlock = block;
	
	return nppAutorelease(action);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end

#pragma mark -
#pragma mark NSObject Acting Category
#pragma mark -
//**********************************************************************************************************
//
//	NSObject Acting Category
//
//**********************************************************************************************************

#pragma mark -
#pragma mark NPPActionItem
//**************************************************
//	NPPActionItem
//**************************************************

@interface NPPActionItem : NSObject

@property (nonatomic, NPP_RETAIN) NPPAction *action;
@property (nonatomic, NPP_COPY) NPPBlockVoid completion;
@property (nonatomic) double beginTime;
@property (nonatomic) double token;

- (id) initWithAction:(NPPAction *)action completion:(NPPBlockVoid)block;

@end

@implementation NPPActionItem

@synthesize action = _action, completion = _completion, beginTime = _beginTime, token = _token;

- (id) initWithAction:(NPPAction *)action completion:(NPPBlockVoid)block
{
	if ((self = [super init]))
	{
		self.action = action;
		self.completion = block;
	}
	
	return self;
}

- (void) dealloc
{
	nppRelease(_action);
	nppRelease(_completion);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

#pragma mark -
#pragma mark NPPActing Category
//**************************************************
//	NPPActing Category
//**************************************************

@interface NSObject(NPPActing) <NPPTimerItem>

@end

@implementation NSObject (NPPActing)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

NPP_CATEGORY_PROPERTY_READONLY(NSMutableDictionary, nppActions);

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

- (void) runAction:(NPPAction *)action withKey:(NSString *)key completion:(NPPBlockVoid)block
{
	NPPActionItem *item = nil;
	NSMutableDictionary *actions = [self nppActions];
	unsigned long long count = (unsigned long long)[actions count] + nppRandomi(0, NPP_MAX_32_HALF);
	
	// Each action has a key, equal keys means the action will be overrided.
	
	// Finds the final key and tegisters the new action.
	key = (key == nil) ? [NSString stringWithFormat:kNPPActionPattern, count] : key;
	item = [[NPPActionItem alloc] initWithAction:action completion:block];
	[actions setObject:item forKey:key];
	nppRelease(item);
	
	// Registers this object for timer callbacks.
	[[NPPTimer instance] addItem:self];
	
	// Makes the initial run.
	[self timerCallBack];
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

- (void) timerCallBack
{
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	NSMutableDictionary *actions = [self nppActions];
	NSArray *keys = [actions allKeys];
	NSString *key = nil;
	
	NPPActionItem *item = nil;
	NPPAction *action = nil;
	double token = 0.0;
	double beginTime = 0.0;
	double currentTime = 0.0;
	float elapsedTime = 0.0f;
	float finalDuration = 0.0f;
	BOOL shouldEnd = NO;
	
	// Looping through all keys.
	// This is a safe way to avoid mutating the collection during a loop.
	for (key in keys)
	{
		// Retrieving the information from action.
		item = [actions objectForKey:key];
		action = item.action;
		token = item.token;
		beginTime = item.beginTime;
		finalDuration = action.finalDuration;
		
		// The absolute time is get once to ensure the very first run will have 0.0 elapsed time.
		currentTime = nppApplicationTime();
		
		// Registers the begin time, if needed.
		if (beginTime == 0.0)
		{
			token = nppGetActionToken();
			beginTime = currentTime;
			
			item.token = token;
			item.beginTime = beginTime;
		}
		
		// Calculates the elapsed time for this ACTION with this TARGET.
		elapsedTime = (float)(currentTime - beginTime);
		elapsedTime = MIN(elapsedTime, finalDuration);
		shouldEnd = (elapsedTime >= finalDuration);
		
		// Executing the block.
		nppBlock(action.actionBlock, self, elapsedTime, token);
		
		// Checks for finished actions and marks it for removal.
		if (shouldEnd)
		{
			[toRemove addObject:key];
			nppBlock(item.completion);
		}
	}
	
	// Removing finished actions.
	for (key in toRemove)
	{
		[self removeActionForKey:key];
	}
	
	nppRelease(toRemove);
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

- (void) runAction:(NPPAction *)action
{
	[self runAction:action withKey:nil completion:nil];
}

- (void) runAction:(NPPAction *)action completion:(NPPBlockVoid)block
{
	[self runAction:action withKey:nil completion:block];
}

- (void) runAction:(NPPAction *)action withKey:(NSString *)key
{
	[self runAction:action withKey:key completion:nil];
}

- (void) runAction:(NPPAction *)action withDelay:(float)seconds
{
	NSArray *sequence = [NSArray arrayWithObjects:
						 [NPPAction waitForDuration:seconds],
						 action,
						 nil];
	
	[self runAction:[NPPAction sequence:sequence] withKey:nil completion:nil];
}

- (void) executeAction:(NPPAction *)action
{
	nppBlock(action.actionBlock, self, action.finalDuration, nppGetActionToken());
}

- (BOOL) hasActions
{
	return ([[self nppActions] count] > 0);
}

- (NPPAction *) actionForKey:(NSString *)key
{
	NPPActionItem *item = [[self nppActions] objectForKey:key];
	return item.action;
}

- (void) removeActionForKey:(NSString *)key
{
	NSMutableDictionary *actions = [self nppActions];
	[actions removeObjectForKey:key];
	
	// Removing from timer, if needed.
	if ([actions count] == 0)
	{
		[[NPPTimer instance] removeItem:self];
	}
}

- (void) removeAllActions
{
	// Removing from timer.
	[[self nppActions] removeAllObjects];
	[[NPPTimer instance] removeItem:self];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end
